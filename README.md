# Realtime obstacle detection from optical flow in panoramic images
### Bachelor Thesis, Andreas Stöckel, 2013, Bielefeld University

**[📕 Download the PDF](astoecke_bachelor_thesis_2013.pdf)**

## Abstract

An important component of mobile robot navigation is obstacle detection.
For this purpose, the target robot platform is equipped with a set of static
laser diodes and an omnidirectional camera. The usage of only four diodes
at a time in conjunction with slow temporal sampling results in a relatively
coarse environmental coverage, which causes small and slim objects (like legs
of tables or chairs) to be often missed.

A previously developed algorithm is capable of detecting obstacles by an-
alyzing time series of spherical panoramic images using implicit optical flow
estimation. The goal of this thesis is to lay the theoretical foundations of the
algorithm and to present performance optimizations allowing real-time oper-
ation on an embedded system. Moreover, measures for the obstacle detection
performance in simulated test runs are developed.

Performance optimization is achieved by a resolution pyramid with coarse-
to-fine refinement in the optical flow estimation step, motion field precalcula-
tion, as well as the use of single instruction multiple data (SIMD) instruction
set extensions in the implementation.

The final implementation fully satisfies the real-time constraint, typically
requiring less than 30 ms for an obstacle detection step on the target system.
While tests in simulated environments show that the algorithm is capable
of mean obstacle detection errors smaller than 0.06 m, the real-world perfor-
mance heavily depends on the quality of the input and especially on correct
robot orientation estimates.

## Compiling the document

Run `latexmk` in the repository root folder and install missing TeX Live
packages using a package manager of your choice.

## License

This document TeX source code and all images are licensed under <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/">CC BY-NC-ND 4.0</a>.
Unless noted otherwise, all other source code is released under the [AGPLv3](https://www.gnu.org/licenses/agpl-3.0.en.html). 

> [!NOTE]
> The system described in this work is protected under [Patent DE102014110201B3](
> https://patents.google.com/patent/DE102014110201B3). Despite what other licenses
> in this repository might say, the author cannot grant any usage rights for this
> patent.

