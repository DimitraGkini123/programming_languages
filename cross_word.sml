
(* βοηθητικη *)
fun trim s =
  let
    val is_space = Char.isSpace
    fun dropWhile p [] = []
      | dropWhile p (x::xs) = if p x then dropWhile p xs else x::xs
    fun dropWhileEnd p xs = List.rev (dropWhile p (List.rev xs))
    val chars = explode s
    val trimmed = dropWhileEnd is_space (dropWhile is_space chars)
  in
    implode trimmed
  end

fun split_line s = String.tokens (fn c => c = #" ") s

fun read_ints ins =
  case TextIO.inputLine ins of
      SOME line => map (valOf o Int.fromString) (split_line (trim line))
    | NONE => raise Fail "Unexpected EOF"

fun read_words ins 0 acc = rev acc
  | read_words ins n acc =
      (case TextIO.inputLine ins of
           SOME line =>
             let val w = trim line in
               if w = "" then raise Fail "Empty word" else read_words ins (n - 1) (w :: acc)
             end
         | NONE => raise Fail "Unexpected EOF")

fun read_pairs ins 0 acc = rev acc
  | read_pairs ins n acc =
      let val nums = read_ints ins in
        case nums of
            [r, c] => read_pairs ins (n - 1) ((r, c) :: acc)
          | _ => raise Fail "Invalid pair line"
      end

fun load_crossword_data filename =
  let val ins = TextIO.openIn filename
      val [rows, cols, black_count, word_count] = read_ints ins
      val black_cells = List.map (fn (r,c) => (r-1, c-1)) (read_pairs ins black_count [])
      val words = read_words ins word_count []
      val _ = TextIO.closeIn ins
  in
    (rows, cols, black_cells, words)
  end

datatype cell = Wall | Blank | Letter of char

fun make_grid r c walls =
  let
    val grid = Array.tabulate (r, fn _ => Array.array (c, Blank))
    fun mark (i, j) = Array.update (Array.sub (grid, i), j, Wall)
    val _ = List.app mark walls
  in
    grid
  end

fun copy_grid grid = Array.tabulate (Array.length grid, fn i => Array.tabulate (Array.length (Array.sub (grid, i)), fn j => Array.sub (Array.sub (grid, i), j)))

fun is_wall Wall = true
  | is_wall _ = false

fun try_insert_word grid path word =
  let
    val word_chars = explode word
    val new_grid = copy_grid grid
    fun aux [] [] = SOME new_grid
      | aux ((x, y)::ps) (ch::chs) =
          (case Array.sub (Array.sub (new_grid, x), y) of
              Wall => NONE
            | Blank => (Array.update (Array.sub (new_grid, x), y, Letter ch); aux ps chs)
            | Letter c => if c = ch then aux ps chs else NONE)
      | aux _ _ = NONE
  in
    if length path <> size word then NONE else aux path word_chars
  end

fun extract_slots grid r c is_row =
  let
    val primary = if is_row then r else c
    val secondary = if is_row then c else r
    fun loop i acc =
      if i >= primary then acc
      else
        let
          fun skip_walls j =
            if j >= secondary then j
            else if is_wall (if is_row then Array.sub (Array.sub (grid, i), j) else Array.sub (Array.sub (grid, j), i))
              then skip_walls (j + 1) else j

          fun find_end j =
            if j >= secondary then j
            else if is_wall (if is_row then Array.sub (Array.sub (grid, i), j) else Array.sub (Array.sub (grid, j), i))
              then j else find_end (j + 1)

          val start = skip_walls 0
          val stop = find_end start
          val acc' = if stop - start >= 2 then
                        let val slot = List.tabulate (stop - start, fn k => if is_row then (i, start + k) else (start + k, i))
                        in slot :: acc end
                      else acc
        in
          loop (i + 1) acc'
        end
  in
    loop 0 []
  end

val horizontal_paths = fn grid => fn r => fn c => extract_slots grid r c true
val vertical_paths = fn grid => fn r => fn c => extract_slots grid r c false

fun solve _ [] grid = SOME grid
  | solve [] _ _ = NONE
  | solve (slot::slots) words grid =
      let
        fun try_words [] = NONE
          | try_words (w::ws) =
              case try_insert_word grid slot w of
                  SOME new_grid =>
                    (case solve slots (List.filter (fn x => x <> w) words) new_grid of
                         SOME g => SOME g
                       | NONE => try_words ws)
                | NONE => try_words ws
      in
        try_words words
      end

fun print_grid grid rows cols =
  let
    fun get_char r c =
      case Array.sub (Array.sub (grid, r), c) of
          Letter ch => str ch
        | _ => " "
    fun print_row r =
      let
        fun loop c acc = if c >= cols then acc else loop (c + 1) (acc ^ get_char r c)
      in
        print (loop 0 "" ^ "\n")
      end
  in
    List.app print_row (List.tabulate (rows, fn i => i))
  end

fun crossword filename =
  let
    val (rows, cols, blacks, words) = load_crossword_data filename
    val grid = make_grid rows cols blacks
    val slots = horizontal_paths grid rows cols @ vertical_paths grid rows cols
  in
    case solve slots words grid of
        SOME solution => (print_grid solution rows cols; print "val it = () : unit\n")
      | NONE => (print "No solution found\n"; print "val it = () : unit\n")
  end





