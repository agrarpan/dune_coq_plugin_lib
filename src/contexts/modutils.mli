open Declarations

(* --- Modules --- *)

(*
 * Pull any functor parameters off the module signature, returning the list of
 * functor parameters and the list of module elements (i.e., fields).
 *)
val decompose_module_signature : module_signature -> (Names.MBId.t * module_type_body) list * structure_body

(*
 * Declare an interactive (i.e., elementwise) module structure, with the
 * functional argument called to populate the module elements by declaration.
 *
 * The optional argument specifies functor parameters.
 *)
val declare_module_structure : ?params:(Constrexpr.module_ast Declaremods.module_params) -> Names.Id.t -> (Names.ModPath.t -> unit) -> Names.ModPath.t

(*
 * Fold over the constant/inductive definitions within a module structure,
 * skipping any module (type) components and any unsupported (e.g., mutual)
 * inductive definitions.
 *
 * Elimination schemes (e.g., `Ind_rect`) are filtered out from the definitions.
 *)
val fold_module_structure_by_decl : 'a -> ('a -> Names.Constant.t -> constant_body -> 'a) -> ('a -> Names.inductive -> Inductive.mind_specif -> 'a) -> module_body -> 'a

(*
 * Same as `fold_module_structure_by_decl` except a single step function
 * accepting a global reference.
 *)
val fold_module_structure_by_glob : 'a -> ('a -> Names.GlobRef.t -> 'a) -> module_body -> 'a

(*
 * Same as `fold_module_structure_by_glob` except an implicit unit accumulator.
 *)
val iter_module_structure_by_glob : (Names.GlobRef.t -> unit) -> module_body -> unit
