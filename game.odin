package game


import rl "vendor:raylib"
import la "core:math/linalg"
import "core:math/rand"


Pair :: struct {x, y: i32}

init_matrix :: proc(mat: ^[$M][$N]bool) {
  coinflip: [2]int = {0, 1}
  for i in 0..<M {
    for j in 0..<N {
      if x := rand.choice(coinflip[:]); x == 0 {
        mat[i][j] = false
      } else {
        mat[i][j] = true
      }
    }
  }
}

draw_matrix :: proc(mat: ^[$M][$N]bool) {
  for i in 0..<M {
    for j in 0..<N {
      x := i * 10
      y := j * 10

      if mat[i][j] {
        rl.DrawRectangle(i32(x), i32(y), 10, 10, rl.BLACK)
      }

    }
  }
}

neighbor_count :: proc(mat: ^[$M][$N]bool, pos: Pair) -> int {
  cnt: int = 0
  for i in -1..=1 {
    for j in -1..=1 {
      if i == 0 && j == 0 {
        continue
      }

      x := (int(pos.x) + i + M) % M
      y := (int(pos.y) + j + N) % N

      if mat[x][y] {
        cnt += 1
      }
    }
  }
  return cnt
}


update_matrix :: proc(mat: ^[$M][$N]bool) {
  changes: [dynamic]Pair
  for i in 0..<M {
    for j in 0..<N {
      cnt := neighbor_count(mat, Pair{i32(i), i32(j)})
      if (mat[i][j] && (cnt < 2 || mat[i][j] && cnt > 3)) || (!mat[i][j] && cnt == 3) {
        append(&changes, Pair{i32(i), i32(j)})
      } 
    }
  }

  for p in changes {
    mat[p.x][p.y] = !mat[p.x][p.y]
  }
}

key_listener :: proc(mat: ^[$M][$N]bool, pause: ^bool) {
  if rl.IsKeyPressed(.R) {
    init_matrix(mat)
  } else if rl.IsKeyPressed(.SPACE) {
    pause^ = !pause^
  }
}



main :: proc() {
  rl.InitWindow(1280, 720, "Game of Life in Odin")
  rl.SetTargetFPS(30)
  defer {
    rl.CloseWindow()
  }

  pause: bool = false


  cellmatrix: [128][72]bool
  
  init_matrix(&cellmatrix)

  for !rl.WindowShouldClose() {
    rl.BeginDrawing()
    rl.ClearBackground(rl.RAYWHITE)
    key_listener(&cellmatrix, &pause)
    draw_matrix(&cellmatrix)
    if !pause {
      update_matrix(&cellmatrix)
    }
    rl.EndDrawing()
  }
}
