{-# OPTIONS --without-K --rewriting #-}

open import lib.Basics
open import lib.types.Coproduct
open import lib.types.Paths
open import lib.types.Pointed
open import lib.types.Pushout
open import lib.types.PushoutFlattening
open import lib.types.PushoutFmap
open import lib.types.Sigma
open import lib.types.Span
open import lib.types.Unit

-- Wedge of two pointed types is defined as a particular case of pushout

module lib.types.Wedge where

module _ {i j} (X : Ptd i) (Y : Ptd j) where

  ⊙∨-span : ⊙Span
  ⊙∨-span = ⊙span X Y ⊙Unit ⊙cst ⊙cst
  ⊙wedge-span = ⊙∨-span

  ∨-span : Span
  ∨-span = ⊙Span-to-Span ⊙∨-span
  wedge-span = ∨-span

  Wedge : Type (lmax i j)
  Wedge = Pushout wedge-span

  infix 80 _∨_
  _∨_ = Wedge

  ⊙Wedge : Ptd (lmax i j)
  ⊙Wedge = ⊙Pushout ⊙wedge-span

  infix 80 _⊙∨_
  _⊙∨_ = ⊙Wedge

module _ {i j} {X : Ptd i} {Y : Ptd j} where

  winl : de⊙ X → X ∨ Y
  winl x = left x

  winr : de⊙ Y → X ∨ Y
  winr y = right y

  wglue : winl (pt X) == winr (pt Y)
  wglue = glue tt

  ⊙winl : X ⊙→ X ⊙∨ Y
  ⊙winl = (winl , idp)

  ⊙winr : Y ⊙→ X ⊙∨ Y
  ⊙winr = (winr , ! wglue)

  module WedgeElim {k} {P : X ∨ Y → Type k}
    (inl* : (x : de⊙ X) → P (winl x)) (inr* : (y : de⊙ Y) → P (winr y))
    (glue* : inl* (pt X) == inr* (pt Y) [ P ↓ wglue ]) where

    private
      module M = PushoutElim inl* inr* (λ _ → glue*)

    f = M.f
    glue-β = M.glue-β unit

  Wedge-elim = WedgeElim.f

  module WedgeRec {k} {C : Type k} (inl* : de⊙ X → C) (inr* : de⊙ Y → C)
    (glue* : inl* (pt X) == inr* (pt Y)) where

    private
      module M = PushoutRec {d = wedge-span X Y} inl* inr* (λ _ → glue*)

    f = M.f
    glue-β = M.glue-β unit

  Wedge-rec = WedgeRec.f

  module ⊙WedgeRec {k} {Z : Ptd k} (g : X ⊙→ Z) (h : Y ⊙→ Z) where

    open WedgeRec (fst g) (fst h) (snd g ∙ ! (snd h)) public

    ⊙f : X ⊙∨ Y ⊙→ Z
    ⊙f = (f , snd g)

    ⊙winl-β : ⊙f ⊙∘ ⊙winl == g
    ⊙winl-β = idp

    ⊙winr-β : ⊙f ⊙∘ ⊙winr == h
    ⊙winr-β = ⊙λ=' (λ _ → idp) $
      ap (_∙ snd g)
         (ap-! f wglue ∙ ap ! glue-β ∙ !-∙ (snd g) (! (snd h)))
      ∙ ∙-assoc (! (! (snd h))) (! (snd g)) (snd g)
      ∙ ap (! (! (snd h)) ∙_) (!-inv-l (snd g))
      ∙ ∙-unit-r (! (! (snd h)))
      ∙ !-! (snd h)

  ⊙Wedge-rec = ⊙WedgeRec.⊙f

  ⊙Wedge-rec-post∘ : ∀ {k l} {Z : Ptd k} {W : Ptd l}
    (k : Z ⊙→ W) (g : X ⊙→ Z) (h : Y ⊙→ Z)
    → k ⊙∘ ⊙Wedge-rec g h == ⊙Wedge-rec (k ⊙∘ g) (k ⊙∘ h)
  ⊙Wedge-rec-post∘ k g h = ⊙λ='
    (Wedge-elim (λ _ → idp) (λ _ → idp)
      (↓-='-in' $ ⊙WedgeRec.glue-β (k ⊙∘ g) (k ⊙∘ h)
                 ∙ lemma (fst k) (snd g) (snd h) (snd k)
                 ∙ ! (ap (ap (fst k)) (⊙WedgeRec.glue-β g h))
                 ∙ ∘-ap (fst k) (fst (⊙Wedge-rec g h)) wglue))
    idp
    where
    lemma : ∀ {i j} {A : Type i} {B : Type j} (f : A → B) {x y z : A} {w : B}
      (p : x == z) (q : y == z) (r : f z == w)
      → (ap f p ∙ r) ∙ ! (ap f q ∙ r) == ap f (p ∙ ! q)
    lemma f idp idp idp = idp

  ⊙Wedge-rec-η : ⊙Wedge-rec ⊙winl ⊙winr == ⊙idf (X ⊙∨ Y)
  ⊙Wedge-rec-η = ⊙λ='
    (Wedge-elim (λ _ → idp) (λ _ → idp)
      (↓-='-in' $ ap-idf wglue
                 ∙ ! (!-! wglue)
                 ∙ ! (⊙WedgeRec.glue-β ⊙winl ⊙winr)))
    idp

  add-wglue : de⊙ (X ⊙⊔ Y) → X ∨ Y
  add-wglue (inl x) = winl x
  add-wglue (inr y) = winr y

  ⊙add-wglue : X ⊙⊔ Y ⊙→ X ⊙∨ Y
  ⊙add-wglue = add-wglue , idp

  module Projl = ⊙WedgeRec (⊙idf X) (⊙cst {X = Y})
  module Projr = ⊙WedgeRec (⊙cst {X = X}) (⊙idf Y)

  projl = Projl.f
  projr = Projr.f
  ⊙projl = Projl.⊙f
  ⊙projr = Projr.⊙f

  module WedgeToProduct = ⊙WedgeRec ((_, pt Y) , idp) ((pt X ,_), idp)

  ∨-⊙to-× : X ⊙∨ Y ⊙→ X ⊙× Y
  ∨-⊙to-× = WedgeToProduct.⊙f

  ∨-to-× : X ∨ Y → de⊙ (X ⊙× Y)
  ∨-to-× = WedgeToProduct.f

  ∨-to-×-glue-β : ap ∨-to-× wglue == idp
  ∨-to-×-glue-β = WedgeToProduct.glue-β
    
  abstract
    ↓-∨to×=cst-in : ∀ {x y} {p p' : (pt X , pt Y) == (x , y)}
      → p == p'
      → p == p' [ (λ w → ∨-to-× w == (x , y)) ↓ wglue ]
    ↓-∨to×=cst-in {p' = idp} q =
      ↓-app=cst-in' (q ∙ ! WedgeToProduct.glue-β)

    ↓-∨to×=cst-out : ∀ {x y} {p p' : (pt X , pt Y) == (x , y)}
      → p == p' [ (λ w → ∨-to-× w == (x , y)) ↓ wglue ]
      → p == p'
    ↓-∨to×=cst-out {p' = idp} q =
      ↓-app=cst-out' q ∙ WedgeToProduct.glue-β

    ↓-∨to×=cst-β : ∀ {x y} {p p' : (pt X , pt Y) == (x , y)}
      (q : p == p')
      → ↓-∨to×=cst-out (↓-∨to×=cst-in q) == q
    ↓-∨to×=cst-β {p' = idp} idp =
        ap (_∙ WedgeToProduct.glue-β) (↓-app=cst-β' {p = wglue} (! WedgeToProduct.glue-β))
      ∙ !-inv-l WedgeToProduct.glue-β

    ↓-∨to×=cst-η : ∀ {x y} {p p' : (pt X , pt Y) == (x , y)}
      (q : p == p' [ (λ w → ∨-to-× w == (x , y)) ↓ wglue ])
      → ↓-∨to×=cst-in (↓-∨to×=cst-out q) == q
    ↓-∨to×=cst-η {p = p} {p' = idp} q =
        ap ↓-app=cst-in'
          ( ∙-assoc (↓-app=cst-out' q) WedgeToProduct.glue-β (! WedgeToProduct.glue-β)
          ∙ ap (↓-app=cst-out' q ∙_) (!-inv-r WedgeToProduct.glue-β)
          ∙ ∙-unit-r (↓-app=cst-out' q))
      ∙ ↓-app=cst-η' q

module Fold {i} {X : Ptd i} = ⊙WedgeRec (⊙idf X) (⊙idf X)
fold = Fold.f
⊙fold = Fold.⊙f

module _ {i i' j j'} {X : Ptd i} {X' : Ptd i'} {Y : Ptd j} {Y' : Ptd j'}
  (fX : X ⊙→ X') (fY : Y ⊙→ Y') where

  wedge-span-map : SpanMap (wedge-span X Y) (wedge-span X' Y')
  wedge-span-map = span-map (fst fX) (fst fY) (idf _)
                      (comm-sqr λ _ → snd fX)
                      (comm-sqr λ _ → snd fY)

  ∨-fmap : X ∨ Y → X' ∨ Y'
  ∨-fmap = Pushout-fmap wedge-span-map

  ⊙∨-fmap : X ⊙∨ Y ⊙→ X' ⊙∨ Y'
  ⊙∨-fmap = ∨-fmap , ap winl (snd fX)

module _ {i i' j j'} {X : Ptd i} {X' : Ptd i'} {Y : Ptd j} {Y' : Ptd j'}
  (eqX : X ⊙≃ X') (eqY : Y ⊙≃ Y') where

  wedge-span-emap : SpanEquiv (wedge-span X Y) (wedge-span X' Y')
  wedge-span-emap = wedge-span-map (⊙–> eqX) (⊙–> eqY)
                  , snd eqX , snd eqY , idf-is-equiv _

  ∨-emap : X ∨ Y ≃ X' ∨ Y'
  ∨-emap = Pushout-emap wedge-span-emap

  ⊙∨-emap : X ⊙∨ Y ⊙≃ X' ⊙∨ Y'
  ⊙∨-emap = ≃-to-⊙≃ ∨-emap (ap winl (snd (fst eqX)))

module _ {i j k} (X : Ptd i) (Y : Ptd j) (Z : Ptd k) where

  ∨-assoc : (X ⊙∨ Y) ∨ Z ≃ X ∨ (Y ⊙∨ Z)
  ∨-assoc = equiv to from to-from from-to where
    module ToInl = WedgeRec {C = X ∨ (Y ⊙∨ Z)} winl (winr ∘ winl) wglue
    module To = WedgeRec {X = X ⊙∨ Y} ToInl.f (winr ∘ winr) (wglue ∙ ap winr wglue)

    to : (X ⊙∨ Y) ∨ Z → X ∨ (Y ⊙∨ Z)
    to = To.f

    module FromInr = WedgeRec {C = (X ⊙∨ Y) ∨ Z} (winl ∘ winr) winr (! (ap winl wglue) ∙ wglue)
    module From = WedgeRec {Y = Y ⊙∨ Z} (winl ∘ winl) FromInr.f (ap winl wglue)

    from : X ∨ (Y ⊙∨ Z) → (X ⊙∨ Y) ∨ Z
    from = From.f

    abstract
      to-from : ∀ x → to (from x) == x
      to-from = Wedge-elim
        (λ x → idp)
        (Wedge-elim (λ y → idp) (λ z → idp) $ ↓-='-in' $ ! $
          ap (to ∘ FromInr.f) wglue
            =⟨ ap-∘ to FromInr.f wglue ⟩
          ap to (ap FromInr.f wglue)
            =⟨ ap (ap to) FromInr.glue-β ⟩
          ap to (! (ap winl wglue) ∙ wglue)
            =⟨ ap-∙ to (! (ap winl wglue)) wglue ⟩
          ap to (! (ap winl wglue)) ∙ ap to wglue
            =⟨ _∙2_ (ap-! to (ap winl wglue) ∙ ap ! (∘-ap to winl wglue ∙ ToInl.glue-β)) To.glue-β ⟩
          ! wglue ∙ wglue ∙ ap winr wglue
            =⟨ ! $ ∙-assoc (! wglue) wglue (ap winr wglue) ⟩
          (! wglue ∙ wglue) ∙ ap winr wglue
            =⟨ ap (_∙ ap winr wglue) (!-inv-l wglue) ⟩
          ap winr wglue
            =∎)
        (↓-∘=idf-in' to from (ap (ap to) From.glue-β ∙ ∘-ap to winl wglue ∙ ToInl.glue-β))

      from-to : ∀ x → from (to x) == x
      from-to = Wedge-elim
        (Wedge-elim (λ x → idp) (λ y → idp) $ ↓-='-in' $
          ! (ap-∘ from ToInl.f wglue ∙ ap (ap from) ToInl.glue-β ∙ From.glue-β))
        (λ z → idp)
        (↓-∘=idf-in' from to $
          ap from (ap to wglue)
            =⟨ ap (ap from) To.glue-β ⟩
          ap from (wglue ∙ ap winr wglue)
            =⟨ ap-∙ from wglue (ap winr wglue) ⟩
          ap from wglue ∙ ap from (ap winr wglue)
            =⟨ From.glue-β ∙2 (∘-ap from winr wglue ∙ FromInr.glue-β) ⟩
          ap winl wglue ∙ ! (ap winl wglue) ∙ wglue
            =⟨ ! $ ∙-assoc (ap winl wglue) (! (ap winl wglue)) wglue ⟩
          (ap winl wglue ∙ ! (ap winl wglue)) ∙ wglue
            =⟨ ap (_∙ wglue) (!-inv-r (ap winl wglue)) ⟩
          wglue
            =∎)

  ⊙∨-assoc : (X ⊙∨ Y) ⊙∨ Z ⊙≃ X ⊙∨ (Y ⊙∨ Z)
  ⊙∨-assoc = ≃-to-⊙≃ ∨-assoc idp
