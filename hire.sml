(* hire.sml *)

fun abs_val x = if x < 0 then ~x else x

fun swap arr i j =
    let val tmp = Array.sub(arr, i)
    in
        Array.update(arr, i, Array.sub(arr, j));
        Array.update(arr, j, tmp)
    end

fun sort_by_diff(diff, order, n) =
    let
        fun outer i =
            if i >= n - 1 then ()
            else let
                fun inner j =
                    if j >= n then ()
                    else (
                        if abs_val (Array.sub(diff, Array.sub(order, i)))
                            < abs_val (Array.sub(diff, Array.sub(order, j))) then
                            swap order i j
                        else ();
                        inner (j + 1)
                    )
            in
                inner (i + 1);
                outer (i + 1)
            end
    in
        outer 0
    end

fun hire filename =
    let
        val inStream = TextIO.openIn filename
        val line = TextIO.inputLine inStream
        val (contractsA, contractsB) =
            case String.tokens Char.isSpace (valOf line) of
                a::b::_ => (valOf (Int.fromString a), valOf (Int.fromString b))
              | _ => raise Fail "Invalid contract line"

        val totalClients = contractsA + contractsB
        val profitA = Array.array(totalClients, 0)
        val profitB = Array.array(totalClients, 0)
        val diff    = Array.array(totalClients, 0)
        val order   = Array.tabulate(totalClients, fn i => i)

        fun readClients i =
            if i = totalClients then ()
            else
                let
                    val l = TextIO.inputLine inStream
                in
                    case String.tokens Char.isSpace (valOf l) of
                        a::b::_ =>
                            let
                                val aVal = valOf (Int.fromString a)
                                val bVal = valOf (Int.fromString b)
                            in
                                Array.update(profitA, i, aVal);
                                Array.update(profitB, i, bVal);
                                Array.update(diff, i, aVal - bVal);
                                readClients (i + 1)
                            end
                      | _ => raise Fail ("Invalid client line " ^ Int.toString(i))
                end

        val _ = readClients 0
        val _ = TextIO.closeIn inStream
        val contractsA_ref = ref contractsA
        val contractsB_ref = ref contractsB
        val totalProfit = ref 0

        val _ = sort_by_diff(diff, order, totalClients)

        fun assign i =
            if i = totalClients then ()
            else
                let
                    val a = Array.sub(order, i)
                    val pA = Array.sub(profitA, a)
                    val pB = Array.sub(profitB, a)
                in
                    if (pA > pB andalso !contractsA_ref > 0) orelse !contractsB_ref = 0 then (
                        totalProfit := !totalProfit + pA;
                        contractsA_ref := !contractsA_ref - 1
                    ) else if !contractsB_ref > 0 then (
                        totalProfit := !totalProfit + pB;
                        contractsB_ref := !contractsB_ref - 1
                    ) else ();
                    assign (i + 1)
                end

        val _ = assign 0
        val _ = print (Int.toString (!totalProfit) ^ "\n")
    in
        ()
    end