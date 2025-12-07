.text
  jal  main
  li   $v0, 10
  syscall
main:
  addi $sp, $sp, -4
  sw   $ra, 0($sp)
  addi $sp, $sp, -4
  sw   $fp, 0($sp)
  move $fp, $sp
  addi $sp, $sp, -12
  li   $t0, 0
  sw   $t0, -4($fp)
  li   $t0, 0
  sw   $t0, -8($fp)
  li   $t0, 0
  sw   $t0, -12($fp)
  li   $t0, 2
  sw   $t0, -4($fp)
  li   $t0, 9
  sw   $t0, -8($fp)
  li   $t0, 1
  sw   $t0, -12($fp)
  b    _label_0
_label_1:
  li   $t0, 0
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 2
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  lw   $t0, -8($fp)
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  rem  $t0, $t0, $t1
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  sne  $t0, $t0, $t1
  beqz $t0, _label_3
  lw   $t0, -12($fp)
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  lw   $t0, -4($fp)
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  mul  $t0, $t0, $t1
  sw   $t0, -12($fp)
  b    _label_3
_label_2:
_label_3:
  lw   $t0, -4($fp)
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  lw   $t0, -4($fp)
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  mul  $t0, $t0, $t1
  sw   $t0, -4($fp)
  li   $t0, 2
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  lw   $t0, -8($fp)
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  div  $t0, $t0, $t1
  sw   $t0, -8($fp)
_label_0:
  li   $t0, 0
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  lw   $t0, -8($fp)
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  sne  $t0, $t0, $t1
  bnez $t0, _label_1
  lw   $t0, -12($fp)
  move $a0, $t0
  li   $v0, 1
  syscall
  li   $t0, 0
  move $sp, $fp
  lw   $fp, 0($sp)
  addi $sp, $sp, 4
  lw   $ra, 0($sp)
  addi $sp, $sp, 4
  jr   $ra
.data
