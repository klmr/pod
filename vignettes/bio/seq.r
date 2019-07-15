#' Test whether input is valid biological sequence
#' @param seq a character vector or \code{seq} object
#' @name seq
#' @export
is_valid_seq = function (seq) {
    UseMethod('is_valid_seq')
}

is_valid_seq.default = function (seq) {
    nucleotides = unlist(strsplit(seq, ''))
    nuc_index = match(nucleotides, c('A', 'C', 'G', 'T'))
    ! any(is.na(nuc_index))
}

`is_valid_seq.bio/seq` = function (seq) {
    TRUE
}

#' Create a biological sequence
#'
#' \code{seq()} creates a set of nucleotide sequences from one or several
#' character vectors consisting of \code{A}, \code{C}, \code{G} and \code{T}.
#' @param ... optionally named character vectors representing DNA sequences.
#' @return Biological sequence equivalent to the input string.
#' @export
seq = function (...) {
    x = toupper(c(...))
    stopifnot(is_valid_seq(x))
    structure(x, class = 'bio/seq')
}

#' Print one or more biological sequences
#' @param seq biological sequences
`print.bio/seq` = function (seq, columns = 60) {
    lines = strsplit(seq, sprintf('(?<=.{%s})', columns), perl = TRUE)
    print_single = function (seq, name) {
        if (! is.null(name)) cat(sprintf('>%s\n', name))
        cat(seq, sep = '\n')
    }
    names = if (is.null(names(seq))) list(NULL) else names(seq)
    Map(print_single, lines, names)
    invisible(seq)
}

mod::register_S3_method('print', 'bio/seq', `print.bio/seq`)

#' Reverse complement
#'
#' The reverse complement of a sequence is its reverse, with all nucleotides
#' substituted by their base complement.
#' @param seq character vector of biological sequences
#' @name seq
#' @export
revcomp = function (seq) {
    nucleotides = strsplit(seq, '')
    complement = lapply(nucleotides, chartr, old = 'ACGT', new = 'TGCA')
    revcomp = lapply(complement, rev)
    structure(vapply(revcomp, paste, character(1L), collapse = ''), class = 'bio/seq')
}

#' Tabulate nucleotides present in sequences
#' @param seq sequences
#' @return A \code{\link[base::table]{table}} for the nucleotides of each
#'  sequence in the input.
#' @name seq
#' @export
table = function (seq) {
    nucleotides = lapply(strsplit(seq, ''), factor, c('A', 'C', 'G', 'T'))
    setNames(lapply(nucleotides, base::table), names(seq))
}
