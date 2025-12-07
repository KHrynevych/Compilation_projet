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
  li   $t0, 4
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 3
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  add  $t0, $t0, $t1
  move $a0, $t0
  li   $v0, 1
  syscall
  li   $t0, 0
  li   $v0, 10
  syscall
  b    _label_1
_label_0:
  li   $t0, 10
  move $a0, $t0
  li   $v0, 1
  syscall
  li   $t0, 0
  li   $v0, 10
  syscall
_label_1:
.data
