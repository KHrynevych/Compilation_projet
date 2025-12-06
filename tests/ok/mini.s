.text
main:
  li   $t0, 2
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 1
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  slt  $t0, $t0, $t1
  beqz $t0, _label_1
  li   $v0, 10
  syscall
  b    _label_1
_label_0:
  li   $v0, 10
  syscall
_label_1:
.data
