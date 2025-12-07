.text
main:
  move $fp, $sp
  addi $sp, $sp, -8
  li   $t0, 0
  sw   $t0, -4($fp)
  li   $t0, 0
  sw   $t0, -8($fp)
  li   $t0, 1
  sw   $t0, -4($fp)
  li   $t0, 6
  sw   $t0, -8($fp)
  li   $t0, 2
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  lw   $t0, -4($fp)
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  add  $t0, $t0, $t1
  sw   $t0, -4($fp)
  li   $t0, 4
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  lw   $t0, -4($fp)
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  add  $t0, $t0, $t1
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  lw   $t0, -8($fp)
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  mul  $t0, $t0, $t1
  sw   $t0, -8($fp)
  lw   $t0, -8($fp)
  move $a0, $t0
  li   $v0, 1
  syscall
  li   $t0, 0
.data
