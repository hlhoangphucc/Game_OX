import 'package:flutter/material.dart';

int rowLength = 10;
int columLength = 11;

enum Direction {
  left,
  right,
  down,
}

enum Tetromino { L, J, I, O, S, Z, T }

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Color(0xFFFFA500), // Mã màu cam
  Tetromino.J: Color(0xFF0000FF), // Mã màu xanh dương
  Tetromino.I: Color(0xFFFF69B4), // Mã màu hồng
  Tetromino.O: Color(0xFFFFFF00), // Mã màu vàng
  Tetromino.S: Color(0xFF008000), // Mã màu xanh lá cây
  Tetromino.Z: Color(0xFFFF0000), // Mã màu đỏ
  Tetromino.T: Color(0xFF800080), // Mã màu tím
};
