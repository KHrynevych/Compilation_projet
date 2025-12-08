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
  addi $sp, $sp, -16
  li   $t0, 0
  sw   $t0, -4($fp)
  li   $t0, 0
  sw   $t0, -8($fp)
  li   $t0, 0
  sw   $t0, -12($fp)
  li   $t0, 0
  sw   $t0, -16($fp)
  li   $t0, 1
  sw   $t0, -4($fp)
  li   $t0, 2
  sw   $t0, -8($fp)
  lw   $t0, -8($fp)
  addi $sp, $sp, -4
  sw   $t0, 0($sp)
  lw   $t0, -4($fp)
  lw   $t1, 0($sp)
  addi $sp, $sp, 4
  slt  $t0, $t0, $t1
  sw   $t0, -12($fp)
  la   $t0, _label_1
  sw   $t0, -16($fp)
  lw   $t0, -4($fp)
  move $a0, $t0
  li   $v0, 1
  syscall
  li   $t0, 0
  lw   $t0, -8($fp)
  move $a0, $t0
  li   $v0, 1
  syscall
  li   $t0, 0
  lw   $t0, -12($fp)
  move $a0, $t0
  li   $v0, 1
  syscall
  li   $t0, 0
  la   $t0, _label_0
  move $a0, $t0
  li   $v0, 4
  syscall
  li   $t0, 0
  move $sp, $fp
  lw   $fp, 0($sp)
  addi $sp, $sp, 4
  lw   $ra, 0($sp)
  addi $sp, $sp, 4
  jr   $ra
.data
_label_1:
  .asciiz "hello"
_label_0:
  .asciiz "hello"
