.text
main:
  li   $t0, 42
  move $a0, $t0
  li   $v0, 1
  syscall
  li   $t0, 0
.data
