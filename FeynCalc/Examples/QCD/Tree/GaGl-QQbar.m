(* ::Package:: *)

(* :Title: GaGl-QQbar                                                     	*)

(*
	This software is covered by the GNU General Public License 3.
	Copyright (C) 1990-2021 Rolf Mertig
	Copyright (C) 1997-2021 Frederik Orellana
	Copyright (C) 2014-2021 Vladyslav Shtabovenko
*)

(* :Summary:  Ga Gl -> Q Qbar, QCD, matrix element squared, tree          	*)

(* ------------------------------------------------------------------------ *)



(* ::Title:: *)
(*Virtual photon-gluon scattering to a quark-antiquark pair*)


(* ::Section:: *)
(*Load FeynCalc and the necessary add-ons or other packages*)


description="Ga Gl -> Q Qbar, QCD, matrix element squared, tree";
If[ $FrontEnd === Null,
	$FeynCalcStartupMessages = False;
	Print[description];
];
If[ $Notebooks === False,
	$FeynCalcStartupMessages = False
];
$LoadAddOns={"FeynArts"};
<<FeynCalc`
$FAVerbose = 0;

FCCheckVersion[9,3,1];


(* ::Section:: *)
(*Generate Feynman diagrams*)


(* ::Text:: *)
(*Nicer typesetting*)


MakeBoxes[p1,TraditionalForm]:="\!\(\*SubscriptBox[\(p\), \(1\)]\)";
MakeBoxes[p2,TraditionalForm]:="\!\(\*SubscriptBox[\(p\), \(2\)]\)";
MakeBoxes[k1,TraditionalForm]:="\!\(\*SubscriptBox[\(k\), \(1\)]\)";
MakeBoxes[k2,TraditionalForm]:="\!\(\*SubscriptBox[\(k\), \(2\)]\)";


diags = InsertFields[CreateTopologies[0, 2 -> 2], {V[1],V[5]}->
	{F[3, {1}], -F[3, {1}]}, InsertionLevel -> {Classes}, Model -> "SMQCD"];

Paint[diags, ColumnsXRows -> {2, 1}, Numbering -> Simple,
	SheetHeader->None,ImageSize->{512,256}];


(* ::Section:: *)
(*Obtain the amplitude*)


amp[0] = FCFAConvert[CreateFeynAmp[diags], IncomingMomenta->{p1,p2},
	OutgoingMomenta->{k1,k2},UndoChiralSplittings->True,ChangeDimension->4,
	TransversePolarizationVectors->{p2}, List->False, SMP->True,
	Contract->True,DropSumOver->True, Prefactor->3/2 SMP["e_Q"]]


(* ::Section:: *)
(*Fix the kinematics*)


FCClearScalarProducts[];
SetMandelstam[s, t, u, p1, p2, -k1, -k2, qQ, 0, SMP["m_u"], SMP["m_u"]];


(* ::Section:: *)
(*Square the amplitude*)


(* ::Text:: *)
(*Now come the usual steps, but with some special features. We do not average over the polarizations of the virtual photon, but use the gauge trick for the sum over its polarizations. In this case the sum goes over all 4 unphysical polarizations,  not just 2.*)


ampSquared[0] = 1/(SUNN^2-1)(amp[0] (ComplexConjugate[amp[0]]))//
	FeynAmpDenominatorExplicit//SUNSimplify[#,Explicit->True,
	SUNNToCACF->False]&//FermionSpinSum[#, ExtraFactor -> 1/2]&//
	DiracSimplify//DoPolarizationSums[#,p1,0,
	VirtualBoson->True]&//DoPolarizationSums[#,p2,k1]&//
	TrickMandelstam[#,{s,t,u, 2SMP["m_u"]^2+qQ^2}]&//Simplify


ampSquaredMassless[0] = ampSquared[0]//ReplaceAll[#,{SMP["m_u"] -> 0}]&//
	TrickMandelstam[#,{s,t,u,qQ^2}]&


ampSquaredMasslessSUNN3[0] =
	Simplify[ampSquaredMassless[0]/.SUNN->3/.qQ->I Q]


(* ::Section:: *)
(*Check the final results*)


knownResults = {
	SMP["e"]^2 SMP["e_Q"]^2 SMP["g_s"]^2 2 (u/t+t/u + 2 Q^2(u+t+Q^2)/(t u))
};
FCCompareResults[{ampSquaredMasslessSUNN3[0]},{knownResults},
Text->{"\tCheck with R. Field, Applications of Perturbative QCD, Eq 4.3.20:",
"CORRECT.","WRONG!"}, Interrupt->{Hold[Quit[1]],Automatic}];
Print["\tCPU Time used: ", Round[N[TimeUsed[],3],0.001], " s."];



