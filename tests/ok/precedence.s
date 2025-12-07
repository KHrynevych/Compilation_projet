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
  addi $sp, $sp, -8
  li   $t0, 0
  sw   $t0, -4($fp)
  li   $t0, 2
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 4
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  div  $t0, $t0, $t1
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 3
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 2
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  mul  $t0, $t0, $t1
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 1
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  add  $t0, $t0, $t1
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  sub  $t0, $t0, $t1
  sw   $t0, -4($fp)
  li   $t0, 3
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 2
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 1
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  add  $t0, $t0, $t1
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  mul  $t0, $t0, $t1
  sw   $t0, -4($fp)
  li   $t0, 6
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 5
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  sne  $t0, $t0, $t1
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 4
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 3
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  sge  $t0, $t0, $t1
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 2
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  li   $t0, 1
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  slt  $t0, $t0, $t1
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  and  $t0, $t0, $t1
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  or  $t0, $t0, $t1
  sw   $t0, -8($fp)
  li   $t0, 1
  beqz $t0, _label_0
  li   $t0, 0
  b    _label_1
_label_0:
  li   $t0, 1
_label_1:
  sw   $t0, -8($fp)
  lw   $t0, -4($fp)
  sub  $t0, $zero, $t0
  sw   $t0, -4($fp)
  move $sp, $fp
  lw   $fp, 0($sp)
  addi $sp, $sp, 4
  lw   $ra, 0($sp)
  addi $sp, $sp, 4
  jr   $ra
.data
