\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dustdoc}[DustVoice modified report class]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ProcessOptions

\LoadClass{report}

\RequirePackage[a5paper,margin=15mm]{geometry}

\RequirePackage{color}
\RequirePackage{tcolorbox}

\RequirePackage{epstopdf}

\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{amsthm}

\RequirePackage{array}
\RequirePackage{caption}
\RequirePackage{longtable}
\RequirePackage{tabu}

\RequirePackage{fix-cm}
\RequirePackage{fontspec}

\RequirePackage{graphicx}
\RequirePackage{wrapfig}
\graphicspath{ {images/} }
\DeclareGraphicsExtensions{.png, .jpg, jpeg, .pdf}

\RequirePackage{float}
\RequirePackage[newfloat]{minted}

\RequirePackage{microtype}
\RequirePackage{hyphenat}
\RequirePackage{seqsplit}

\RequirePackage{titling}
\RequirePackage{titlesec}
\RequirePackage{titletoc}

\RequirePackage{hyperref}

\hypersetup{
    colorlinks=true,
    linkcolor=magenta,
    urlcolor=blue,
    pageanchor=false
}

\setminted{breaklines=true,breakanywhere=true,breakbytoken=false,breakbytokenanywhere=false,tabsize=4,frame=single,framesep=.5em,samepage=false}
\setmintedinline{breaklines=true,breakanywhere=true,breakbytoken=false,breakbytokenanywhere=false}

\newcommand{\admonition}[2]{\textbf{#1}: {#2}}
\newcommand{\rolered}[1]{ \textcolor{red}{#1} }
\newcommand{\roleblue}[1]{ \textcolor{blue}{#1} }

\newtheorem{example}{Example}
\newtheorem{note}{Note}

\newenvironment{sidebar}[2]
{\begin{tcolorbox}
    \begin{bf}
        #1
    \end{bf}
    \\#2}
{\end{tcolorbox}}

\colorlet{admonitionBG}{black!5!white}
\definecolor{draculaBlue}{HTML}{6272a4}
\definecolor{draculaYellow}{HTML}{f1fa8c}
\definecolor{draculaRed}{HTML}{ff5555}
\definecolor{draculaOrange}{HTML}{ffb86c}
\definecolor{draculaPink}{HTML}{ff79c6}
\definecolor{draculaFG}{HTML}{f8f8f2}
\definecolor{draculaBG}{HTML}{282a36}

\newenvironment{NOTE}
{\begin{tcolorbox}[before upper={\setlength{\parindent}{1.5em}\noindent}, colback=admonitionBG,coltitle=draculaFG,colframe=draculaBlue,colbacktitle=draculaBlue,title=NOTE]}
{\end{tcolorbox}}

\newenvironment{TIP}
{\begin{tcolorbox}[before upper={\setlength{\parindent}{1.5em}\noindent},colback=admonitionBG,coltitle=draculaBG,colframe=draculaYellow,colbacktitle=draculaYellow,title=TIP]}
{\end{tcolorbox}}

\newenvironment{IMPORTANT}
{\begin{tcolorbox}[before upper={\setlength{\parindent}{1.5em}\noindent},colback=admonitionBG,coltitle=draculaFG,colframe=draculaRed,colbacktitle=draculaRed,title=IMPORTANT]}
{\end{tcolorbox}}

\newenvironment{WARNING}
{\begin{tcolorbox}[before upper={\setlength{\parindent}{1.5em}\noindent},colback=admonitionBG,coltitle=draculaBG,colframe=draculaOrange,colbacktitle=draculaOrange,title=WARNING]}
{\end{tcolorbox}}

\newenvironment{CAUTION}
{\begin{tcolorbox}[before upper={\setlength{\parindent}{1.5em}\noindent},colback=admonitionBG,coltitle=draculaBG,colframe=draculaPink,colbacktitle=draculaPink,title=CAUTION]}
{\end{tcolorbox}}

\newenvironment{packagetable}
{\begin{longtabu}to \textwidth [b]{X[1,r]|X[1,l]}}
{\end{longtabu}}

\newenvironment{mintedlisting}{%
    \begin{listing}[H]
        \captionsetup{%
            format=plain,
            width=.75\textwidth,
            type=listing,
            justification=centering,
            singlelinecheck=off,
            position=bottom,
            skip=0pt,
            name=Code-Listing
        }
}{%
    \end{listing}
}

\newcommand{\chapterbreak}{\clearpage}
\newcommand{\sectionbreak}{\clearpage}
\newcommand{\subsectionbreak}{\clearpage}
\newcommand{\subsubsectionbreak}{\clearpage}
\dottedcontents{chapter}[1.5em]{}{1.5em}{1pc}
\dottedcontents{section}[3.25em]{}{3.25em}{1pc}
\dottedcontents{subsection}[5em]{}{5em}{1pc}
\dottedcontents{subsubsection}[6.75em]{}{6.75em}{1pc}

\newcommand{\hreffn}[2]{\href{#1}{#2}\footnote{#1}}

\setlength{\parindent}{1.5em}
\setlength{\parskip}{0.0pt plus 1.0pt}

\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{3}

\pagenumbering{gobble}

\renewcommand\maketitle{
    \begin{titlingpage}
        \begin{center}
            \includegraphics[width=\textwidth]{arch.png}\par\vspace{10em}
            {\huge \thetitle}\par\vspace{2.5em}
            {\LARGE \theauthor}\par\vspace{2.5em}
            {\large \thedate}\par
        \end{center}
    \end{titlingpage}
}
