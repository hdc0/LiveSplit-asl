#!/usr/bin/env python3

import argparse
import pathlib
import pefile
import re
import sys

PROCESS_NAME = 'tarzan'
ASL_INDENT = '\t'

def main():
	ap = argparse.ArgumentParser(description='Create a Tarzan (PC) '
		'ASL autosplitter for the provided game executables')
	ap.add_argument('exe_dir', nargs='?', default='.', type=pathlib.Path,
		help='the directory to search for Tarzan exe files')
	ap.add_argument('--asl', default=sys.stdout, type=argparse.FileType('w'),
		help='write ASL script to this file rather than to stdout')
	ap.add_argument('-r', '--recursive', action='store_true',
		help='search for exe files recursively')
	args = ap.parse_args()

	write_tarzan_asl(**vars(args))

def write_tarzan_asl(exe_dir, asl, recursive):
	# Search for Tarzan exe files and analyze them
	versions = {}
	for exe_file in exe_dir.glob(('**/' if recursive else '') + '*.exe'):
		try:
			version = GameVersion(exe_file)
		except RuntimeError as err:
			print(f'{exe_file}: {err}', file=sys.stderr)
			continue
		versions[version.tmstmp] = version

	# Create ASL file
	versions = tuple(versions[tmstmp] for tmstmp in sorted(versions))
	AslWriter(versions).write(asl)

class GameVersion:
	def __init__(self, exe_path):
		self.pe = pefile.PE(exe_path)
		self.exe = self.pe.__data__
		self.tmstmp = self.pe.FILE_HEADER.TimeDateStamp
		self.tmstmp_pos = \
			self.pe.FILE_HEADER.get_field_absolute_offset('TimeDateStamp')
		self.name = self.detect_version()
		self.addrs = self.find_addrs()

	def detect_version(self):
		# Detect language
		if self.exe.find(b'T:\GRAFIX\SCREENS\_pc_bin\TIT_BACK.TEX') != -1:
			lang = 'US'
		elif self.exe.find(b'T:\LANGUAGE\English\_pc_bin\TIT_BACK.TEX') != -1:
			lang = 'UK'
		else:
			m = re.findall(br'T:\\LANGUAGE\\([^\\]+)\\_pc_bin\\TIT_BACK.TEX',
				self.exe)
			if len(m) != 1:
				raise RuntimeError('Language detection failed')
			lang = m[0].decode('ascii')

		version = ['PC', lang]
		if self.tmstmp >= 0x38C4E96E:
			version.append('Patched')
		return ', '.join(version)

	def find_addrs(self):
		return {
			('int', 'ClaytonCountdown'): self.find_addr(
				br'\x89\x7E\x18'             # mov [esi+18h], edi
				br'\xA1(....)'               # mov eax, ClaytonCountdown
				br'\x48'                     # dec eax
			)[0],
			('byte', 'ReachedUmbrella'): self.find_addr(
				br'\x66\xC7\x43\x48\x02\x00' # mov word ptr [ebx+48h], 2
				br'\x80\x0D(....)\x40'       # or ReachedUmbrella, 40h
				br'\x83\xC4\x0C'             # add esp, 0Ch
			)[0],
			('short', 'SaborDefeats'): self.find_addr(
				br'\xD3\xE2'                 # shl edx, cl
				br'\x66\x09\x15(....)'       # or SaborDefeats, dx
				br'\x8A\x4F\x75'             # mov cl, [edi+75h]
			)[0],
			('byte', 'Level'): self.find_addr(
				br'\x8A\x01'                 # mov al, [ecx]
				br'\xA2(....)'               # mov Level, al
				br'\x33\xC9'                 # xor ecx, ecx
			)[0],
			('int', 'InGame'): self.find_addr(
				br'\x75\x23'                 # jnz 25h
				br'\xA1(....)'               # mov eax, InGame
				br'\x85\xC0'                 # test eax, eax
				br'\x74\x1A'                 # jz 1Ch
			)[0]
		}

	def find_addr(self, pattern):
		matches = re.findall(pattern, self.exe)
		if len(matches) == 0:
			raise RuntimeError('No matches found')
		if len(matches) > 1:
			raise RuntimeError('Multiple matches found')
		match = (matches[0],) if type(matches[0]) is bytes else matches[0]

		return tuple(self.va2rva(int.from_bytes(m, byteorder='little'))
			for m in match)

	def va2rva(self, va):
		return va - self.pe.OPTIONAL_HEADER.ImageBase

class AslWriter:
	def __init__(self, versions):
		self.versions = versions

	def write(self, out):
		out.write('\n'.join(self.create_state_descriptors() + (
			self.create_init_action(),
			self.create_update_action(),
			self.create_start_action(),
			self.create_split_action()
		)).replace('\t', ASL_INDENT))

	def create_state_descriptors(self):
		return tuple(self.create_state_descriptor(ver)
			for ver in self.versions)

	def create_state_descriptor(self, ver):
		max_type_len = max(len(key[0]) for key in ver.addrs.keys())
		max_name_len = max(len(key[1]) for key in ver.addrs.keys())
		return f'''\
state("{PROCESS_NAME}", "{ver.name}")
{{
''' + \
'\n'.join(
	f'\t{typ: <{max_type_len}} {name: <{max_name_len}} : 0x{addr:06X};'
	for (typ, name), addr in ver.addrs.items()
) + f'''
}}
'''

	def create_init_action(self):
		return '''\
init
{
	var versions = new dynamic[,]
	{
''' + \
',\n'.join(
	f'\t\t{{ 0x{ver.tmstmp:08X}, 0x{ver.tmstmp_pos:03X}, "{ver.name}" }}'
	for ver in self.versions
) + '''
	};
	var baseAddr = modules.First().BaseAddress;
	for (int i = 0; i < versions.GetLength(0); ++i)
	{
		var timestamp = versions[i, 0];
		IntPtr posTimestamp = baseAddr + versions[i, 1];
		var name = versions[i, 2];
		if (memory.ReadValue<int>(posTimestamp) == timestamp)
		{
			version = name;
			break;
		}
	}
}
'''

	@staticmethod
	def create_update_action():
		return '''\
update
{
	return version != "";
}
'''

	@staticmethod
	def create_start_action():
		return '''\
start
{
	return current.InGame != 0;
}
'''

	@staticmethod
	def create_split_action():
		return '''\
split
{
	if (current.InGame == 0) return false;

	const int Level_Welcome = 1;
	const int Level_Sabor = 6;
	const int Level_Clayton = 13;

	if (current.Level == Level_Sabor)
	{
		return old.SaborDefeats != current.SaborDefeats && (current.SaborDefeats & 4) != 0;
	}
	else if (current.Level == Level_Clayton)
	{
		return old.ClaytonCountdown != current.ClaytonCountdown;
	}
	else if (current.Level >= Level_Welcome && current.Level < Level_Clayton)
	{
		return old.ReachedUmbrella != current.ReachedUmbrella && (current.ReachedUmbrella & 0x40) != 0;
	}
}
'''

if __name__ == '__main__':
	main()
