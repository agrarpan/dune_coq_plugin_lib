open Util

(*
 * Basic utilities for collections, optionals, and so on
 *)

(* --- Optionals --- *)
       
(* This should be in the standard library, but isn't bound for some reason *)
let map_default f default x =
  if Option.has_some x then f (Option.get x) else default

(* Monadic guard for option. *)
let guard (b : bool) : unit option =
  if b then Some () else None

(* --- Lists --- *)

(* Get the last element of a list *)
let last (l : 'a list) : 'a =
  List.hd (List.rev l)

(* Get all but the last element of a list *)
let all_but_last (l : 'a list) : 'a list =
  List.rev (List.tl (List.rev l))

(* Snoc *)
let snoc (a : 'a) (l : 'a list) : 'a list =
  List.append l [a]

(* Take n elements of a list *)
let rec take (i : int) (l : 'a list) : 'a list =
  if i = 0 then
    []
  else
    match l with
    | [] ->
       []
    | h :: tl ->
       h :: (take (i - 1) tl)
      
(* Drop the first n elements from a list *)
let rec drop n xs =
  if n == 0
  then xs
  else drop (n - 1) (List.tl xs)

(* Take all but n elements of a list *)
let take_except (i : int) (l : 'a list) : 'a list =
  take (List.length l - i) l

(* Like take, but return the remainder too *)
let rec take_split (i : int) (l : 'a list) : ('a list * 'a list) =
  if i = 0 then
    ([], l)
  else
    match l with
    | [] ->
       ([], [])
    | h :: tl ->
       let (before, after) = take_split (i - 1) tl in
       (h :: before, after)

(*
 * Remove duplicates from a list
 *)
let rec unique (eq : 'a -> 'a -> bool)  (l : 'a list) : 'a list =
  match l with
  | [] -> []
  | h :: t -> h :: (List.filter (fun a -> not (eq h a)) (unique eq t))

(*
 * Map a function over a list, then flatten the result
 *)
let flat_map (f : 'a -> 'b list) (l : 'a list) : 'b list =
  List.flatten (List.map f l)

(*
 * Map elements of a list to optionals, then filter out Nones.
 * Only in OCaml 4.08.0 onward, so we implement ourselves.
 *)
let filter_map f l =
  let f_somes = List.filter (fun o -> Option.has_some o) (List.map f l) in
  List.map Option.get f_somes
               
(*
 * Return true if a list has length > 0
 *)
let non_empty (l : 'a list) : bool =
  List.length l > 0

(*
 * Returns the offset of an element that satisfies p in a
 *)
let find_off (a : 'a list) (p : 'a -> bool) : int =
  let rec find_rec a p n =
    match a with
    | [] -> failwith "not found"
    | h :: tl ->
       if p h then
         n
       else
         find_rec tl p (n + 1)
  in find_rec a p 0

(*
 * All combinations of elements in a list
 *)
let rec combinations (l : 'a list) =
  match l with
  | [] -> []
  | h :: t -> List.append (List.map (fun e -> (h, e)) t) (combinations t)

(*
 * Cartesian product of two lists
 * From http://stackoverflow.com/questions/1507496/ocaml-permutation-of-every-value-in-two-sets-how-to-translate-this-from-java
 *)
let cartesian (l1 : 'a list) (l2 : 'b list) : ('a * 'b) list =
  List.concat (List.map (fun a -> List.map (fun b -> (a, b)) l2) l1)

(*
 * Combine all permutations of pairs of elements in lists l1 and l2 via f
 *)
let combine_cartesian (f : 'a -> 'b -> 'c) (l1 : 'a list) (l2 : 'b list) : 'c list =
  List.map (fun (a, b) -> f a b) (cartesian l1 l2)

(*
 * Turns an array of lists into a list of arrays
 *)
let combine_cartesian_append (al : 'a list array) : 'a array list =
  let al' = Array.to_list (Array.map (List.map (fun a -> [a])) al) in
  if (Array.length al) <= 1 then
    List.map Array.of_list (List.concat al')
  else
    List.map Array.of_list (List.fold_left (combine_cartesian List.append) (List.hd al') (List.tl al'))

             
(* Map3 *)
let rec map3 (f : 'a -> 'b -> 'c -> 'd) l1 l2 l3 : 'd list =
  match (l1, l2, l3) with
  | (h1 :: t1, h2 :: t2, h3 :: t3) ->
     let r = f h1 h2 h3 in r :: map3 f t1 t2 t3
  | _ -> []

(*
 * Creates a list of the range of min to max, excluding max
 * This is an auxiliary function renamed from seq in template-coq
 *)
let rec range (min : int) (max : int) : int list =
  if min < max then
    min :: range (min + 1) max
  else
    []

(* Creates a list from the index 1 to max, inclusive *)
let from_one_to (max : int) : int list =
  range 1 (max + 1)

(*
 * This is an auxiliary function from StackOverflow
 * Splits a list at an index
 *)
let rec split_at (n : int) (l : 'a list) : (('a list) * ('a list)) =
  if n = 0 then
    ([], l)
  else
    match l with
      h :: t ->
        let (l1, l2) = split_at (n - 1) t in
        (h :: l1, l2)
    | [] ->
       ([], [])

(* Try to get the second element of a list, defaulting
   to the first, raising NotFound if empty. *)
let list_snd (xs : 'a list) : 'a =
  match xs with
  | x :: y :: _ -> y
  | xs -> List.hd xs
  
(* Compare whether all elements of two lists of equal length are equal. *)
let rec list_eq (cmp : 'a -> 'a -> bool) xs ys : bool =
  match xs, ys with
  | [], [] -> true
  | x :: xs', y :: ys' -> cmp x y && list_eq cmp xs' ys'
  | _, _ -> false
          
(* Compare if all elements of a single list are equal. *)
let all_eq (cmp : 'a -> 'a -> bool) xs : bool =
  match xs with
  | [] -> true
  | x :: xs' -> List.for_all (fun y -> cmp x y) xs'
 
(* Count length of shared prefix between lists. *)
let rec count_shared_prefix (cmp : 'a -> 'a -> bool) xs ys  : int =
  match xs, ys with
  | x :: xs', y :: ys' ->
     if cmp x y then 1 + count_shared_prefix cmp xs' ys' else 0
  | _, _ -> 0

      
(* --- Tuples --- *)
             
(* Map f over a tuple *)
let map_tuple (f : 'a -> 'b) ((a1, a2) : ('a * 'a)) : ('b * 'b) =
  (f a1, f a2)
    
(* Fold f over a tuple *)
let fold_tuple (f : 'a -> 'b -> 'c) ((a, b) : ('a * 'b)) : 'c =
  f a b

(* Apply a function twice with a directionality indicator *)
let twice (f : 'a -> 'a -> bool -> 'b) (a1 : 'a) (a2 : 'a) : 'b * 'b  =
  let forward = f a1 a2 true in
  let backward = f a2 a1 false in
  (forward, backward)

(* Reverse a tuple *)
let reverse ((a, b) : 'a * 'b) : 'b * 'a =
  (b, a)

(* Pair the outputs of two functions on the same input *)
let pair (f : 'a -> 'b) (g : 'a -> 'c) (x : 'a) =
  (f x, g x)

(* --- Propositions --- *)
        
(* Always true *)
let always_true _ = true

(* Check that p a and p b are both true *)
let and_p (p : 'a -> bool) (o : 'a) (n : 'a) : bool =
  p o && p n

(* --- Control structures --- *)

let map_if_else f g b x = if b then f x else g x
let map_if f b x = map_if_else f (fun a -> a) b x

(* --- Functions --- *)

(* Flip the first and second parameters of a function. *)
let flip f = fun x y -> f y x

(* --- Common helper functions --- *)
                     
(*
 * The identity function
 *)
let id (a : 'a) =
  a

(* Constant ID *)
let k_fresh = ref (1)

(*
 * Get a fresh constant identifier
 *)
let fid () : int =
  let id = !k_fresh in
  k_fresh := id + 1;
  id
