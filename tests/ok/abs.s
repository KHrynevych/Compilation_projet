.text
  jal  main
  li   $v0, 10
  syscall
abso:
  addi $sp, $sp, -4
  sw   $ra, 0($sp)
  addi $sp, $sp, -4
  sw   $fp, 0($sp)
  move $fp, $sp
  li   $t0, 0
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  lw   $t0, 8($fp)
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  slt  $t0, $t0, $t1
  beqz $t0, _label_0
  lw   $t0, 8($fp)
  sub  $t0, $zero, $t0
  move $sp, $fp
  lw   $fp, 0($sp)
  addi $sp, $sp, 4
  lw   $ra, 0($sp)
  addi $sp, $sp, 4
  jr   $ra
  b    _label_1
_label_0:
  lw   $t0, 8($fp)
  move $sp, $fp
  lw   $fp, 0($sp)
  addi $sp, $sp, 4
  lw   $ra, 0($sp)
  addi $sp, $sp, 4
  jr   $ra
_label_1:
  move $sp, $fp
  lw   $fp, 0($sp)
  addi $sp, $sp, 4
  lw   $ra, 0($sp)
  addi $sp, $sp, 4
  jr   $ra
main:
  addi $sp, $sp, -4
  sw   $ra, 0($sp)
  addi $sp, $sp, -4
  sw   $fp, 0($sp)
  move $fp, $sp
  addi $sp, $sp, -8
  li   $t0, 0
  sw   $t0, -4($fp)
  li   $t0, 3
  sub  $t0, $zero, $t0
  sw   $t0, -4($fp)
  li   $t0, 0
  sw   $t0, -8($fp)
  lw   $t0, -4($fp)
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  jal  abso
  addi $sp, $sp, 4
  sw   $t0, -8($fp)
  lw   $t0, -8($fp)
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
