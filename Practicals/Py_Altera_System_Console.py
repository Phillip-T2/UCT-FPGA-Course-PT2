"""
Python based abstraction for the Altera System Console interface
-----------------------------------------------------------------------------"""

import sys
import time
import subprocess
#-------------------------------------------------------------------------------

class SystemConsole:
    def __init__(self):
        command = 'C:/altera_lite/25_1std/quartus/sopc_builder/bin/system-console.exe --cli --disable_readline'
        sys.stdout.flush()
        self.console = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        sys.stdout.flush()

    def __del__(self):
        self.console.kill()

    def dump_output(self):
        self.console.stdout.read1()

    def print_output(self):
        print(self.read_output()); sys.stdout.flush()

    def read_output(self):
        result = b''
        while True:
            out = self.console.stdout.read1(1)
            if out == b'%':
                # Read the space and exit
                out = self.console.stdout.read1(1)
                return bytes.decode(result, 'utf-8')
            else:
                result = result + out

    def cmd(self, cmd_string, verbose=True):
        if verbose:
            print(f'% {cmd_string}')
        self.console.stdin.write(bytes(f'{cmd_string}\n', 'utf-8'))
        self.console.stdin.flush()


#-------------------------------------------------------------------------------

print("Starting System Console..."); sys.stdout.flush()
fpga = SystemConsole()
fpga.print_output()

fpga.cmd('set masters [get_service_paths master]')
fpga.print_output()
fpga.cmd('set master [ lindex $masters 0 ]')
fpga.print_output()
fpga.cmd('open_service master $master')
fpga.print_output()

start = time.time()
for n in range(64):
    fpga.cmd('master_read_32 $master 0x04000000 1')
    fpga.print_output()
    fpga.cmd(f'master_write_32 $master 0x04000004 {n}')
    fpga.print_output()
end = time.time()
print(f'Verbose interface took {end - start} seconds'); sys.stdout.flush()

start = time.time()
for n in range(1024):
    fpga.cmd(f'master_write_32 $master 0x04000004 {n}', verbose=False)
    fpga.dump_output()
end = time.time()
print(f'Quiet write took {end - start} seconds'); sys.stdout.flush()

fpga.cmd(f'master_write_32 $master 0x04000004 0x55555555', verbose=False)
fpga.dump_output()

start = time.time()
fpga.cmd(f'master_write_32 $master 0x0 {{ 1 2 3 4 5 6 7 8 }}')
fpga.print_output()
end = time.time()
print(f'Writing 8 words took {end - start} seconds'); sys.stdout.flush()

fpga.cmd(f'master_read_32 $master 0x0 8')
fpga.print_output()

a = list(range(1024))
start = time.time()
fpga.cmd(f'master_write_32 $master 0x0 {{ {" ".join(map(str, a))} }}', verbose=True)
fpga.print_output()
end = time.time()
print(f'Writing 1024 words took {end - start} seconds'); sys.stdout.flush()
# -------------------------------------------------------------------------------

def read_register(address):
    fpga.cmd(f'master_read_32 $master {0x04000000 + address*4} 1', verbose=False)
    return int(fpga.read_output().strip(), 0)

def write_register(address, value):
    fpga.cmd(f'master_write_32 $master {0x04000000 + address*4} {value}', verbose=False)
    fpga.dump_output()
#-------------------------------------------------------------------------------

print('\nRunning electronic level...'); sys.stdout.flush()
while True:
    X = read_register(0x10)
    Y = read_register(0x11)
    Z = read_register(0x12)

    if X & 0x80000000: X -= 0x100000000
    if Y & 0x80000000: Y -= 0x100000000
    if Z & 0x80000000: Z -= 0x100000000

    X //= 10;
    if X < -5: X = -5
    if X >  5: X =  5

    if X > 0: write_register(0x01, 0x30 >>  X)
    else:     write_register(0x01, 0x30 << -X)
#-------------------------------------------------------------------------------