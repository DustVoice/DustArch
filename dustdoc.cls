\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dustdoc}[DustVoice's modified report class]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ProcessOptions

\LoadClass{report}

\RequirePackage[a5paper,margin=15mm]{geometry}

\RequirePackage{amssymb}
\RequirePackage{array}
\RequirePackage{caption}
\RequirePackage{color}
\RequirePackage{epstopdf}
\RequirePackage{fix-cm}
\RequirePackage{fontspec}
\RequirePackage{graphicx}
\RequirePackage[pdfpagelabels]{hyperref}
\RequirePackage{hyphenat}
\RequirePackage{microtype}
\RequirePackage[newfloat]{minted}
\RequirePackage{tcolorbox}
\RequirePackage{titling}
\RequirePackage{titlesec}
\RequirePackage{titletoc}
\RequirePackage{wrapfig}

\RequirePackage{longtable}
\RequirePackage{tabu}



\graphicspath{ {images/} }
\DeclareGraphicsExtensions{.png, .jpg, jpeg, .pdf}

%\pagecolor{black}

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

\renewenvironment{quotation}
{   \leftskip 4em \begin{em} }
{\end{em}\par }

\def\signed#1{{\leavevmode\unskip\nobreak\hfil\penalty50\hskip2em
\hbox{}\nobreak\hfil\raise-3pt\hbox{(#1)}%
\parfillskip=0pt \finalhyphendemerits=0 \endgraf}}

\newsavebox\mybox

\newenvironment{aquote}[1]
{\savebox\mybox{#1}\begin{quotation}}
{\signed{\usebox\mybox}\end{quotation}}

\newenvironment{tquote}[1]
{  {\bf #1} \begin{quotation} \\ }
{ \end{quotation} }

\newenvironment{asciidocbox}
{\leftskip6em\rightskip6em\par}
{\par}

\newenvironment{titledasciidocbox}[1]
{\leftskip6em\rightskip6em\par{\bf #1}\vskip-0.6em\par}
{\par}

\newenvironment{preamble}
{}
{}

\newenvironment{sidebar}[2]
{\begin{tcolorbox}
    \begin{bf}
        #1
    \end{bf}
    \\#2}
{\end{tcolorbox}}

\newenvironment{comment*}
{\leftskip6em\rightskip6em\par}
{\par}

\newenvironment{remark*}
{\leftskip6em\rightskip6em\par}
{\par}

\let\Contentsline\contentsline
\renewcommand\contentsline[3]{\Contentsline{#1}{#2}{}}



\colorlet{admonitionBG}{black!5!white}
\definecolor{draculaBlue}{HTML}{6272a4}
\definecolor{draculaYellow}{HTML}{f1fa8c}
\definecolor{draculaRed}{HTML}{ff5555}
\definecolor{draculaOrange}{HTML}{ffb86c}
\definecolor{draculaPink}{HTML}{ff79c6}
\definecolor{draculaFG}{HTML}{f8f8f2}
\definecolor{draculaBG}{HTML}{282a36}

\newenvironment{NOTE}
{\begin{tcolorbox}[before upper={\setlength{\parskip}{8pt}},colback=admonitionBG,coltitle=draculaFG,colframe=draculaBlue,colbacktitle=draculaBlue,title=NOTE]}
{\end{tcolorbox}}

\newenvironment{TIP}
{\begin{tcolorbox}[before upper={\setlength{\parskip}{8pt}},colback=admonitionBG,coltitle=draculaBG,colframe=draculaYellow,colbacktitle=draculaYellow,title=TIP]}
{\end{tcolorbox}}

\newenvironment{IMPORTANT}
{\begin{tcolorbox}[before upper={\setlength{\parskip}{8pt}},colback=admonitionBG,coltitle=draculaFG,colframe=draculaRed,colbacktitle=draculaRed,title=IMPORTANT]}
{\end{tcolorbox}}

\newenvironment{WARNING}
{\begin{tcolorbox}[before upper={\setlength{\parskip}{8pt}},colback=admonitionBG,coltitle=draculaBG,colframe=draculaOrange,colbacktitle=draculaOrange,title=WARNING]}
{\end{tcolorbox}}

\newenvironment{CAUTION}
{\begin{tcolorbox}[before upper={\setlength{\parskip}{8pt}},colback=admonitionBG,coltitle=draculaBG,colframe=draculaPink,colbacktitle=draculaPink,title=CAUTION]}
{\end{tcolorbox}}

\newenvironment{packagetable}
{\begin{longtabu}to \textwidth [b]{X[1,r]|X[1,l]}}
{\end{longtabu}}

\newenvironment{mintedlisting}{\captionsetup{format=plain,width=.75\textwidth,type=listing}}{}



\setcounter{secnumdepth}{5}
\setcounter{tocdepth}{5}

\titleclass{\subsubsubsection}{straight}[\subsection]
\newcounter{subsubsubsection}[subsubsection]
\renewcommand\thesubsubsubsection{\thesubsubsection.\arabic{subsubsubsection}}
\titleformat{\subsubsubsection}[hang]{\normalfont\normalsize\bfseries}{\thesubsubsubsection}{1em}{}
\titlespacing*{\subsubsubsection}{0pt}{3.25ex plus 1ex minus .2ex}{1.5ex plus .2ex}

\titleclass{\subsubsubsubsection}{straight}[\subsection]
\newcounter{subsubsubsubsection}[subsubsubsection]
\renewcommand\thesubsubsubsubsection{\thesubsubsubsection.\arabic{subsubsubsection}}
\titleformat{\subsubsubsubsection}[hang]{\normalfont\normalsize\bfseries}{\thesubsubsubsubsection}{1em}{}
\titlespacing*{\subsubsubsubsection}{0pt}{3.25ex plus 1ex minus .2ex}{1.5ex plus .2ex}

\renewcommand\theparagraph{\thesubsubsubsubsection.\arabic{paragraph}}

\makeatletter
\renewcommand\paragraph{\@startsection{paragraph}{6}{\z@}%
{3.25ex \@plus1ex \@minus.2ex}%
{-1em}%
{\normalfont\normalsize\bfseries}}
\renewcommand\subparagraph{\@startsection{subparagraph}{7}{\parindent}%
{3.25ex \@plus1ex \@minus .2ex}%
{-1em}%
{\normalfont\normalsize\bfseries}}
\def\toclevel@subsubsubsection{4}
\def\toclevel@subsubsubsubsection{5}
\def\toclevel@paragraph{6}
\def\toclevel@subparagraph{7}
\makeatother

\newcommand{\chapterbreak}{\clearpage}
\newcommand{\sectionbreak}{\clearpage}
\newcommand{\subsectionbreak}{\clearpage}
\newcommand{\subsubsectionbreak}{\clearpage}
\newcommand{\subsubsubsectionbreak}{\clearpage}
\newcommand{\subsubsubsubsectionbreak}{\clearpage}
\dottedcontents{chapter}[1.2em]{}{1.2em}{1pc}
\dottedcontents{section}[3.6em]{}{2.4em}{1pc}
\dottedcontents{subsection}[6.0em]{}{3.6em}{1pc}
\dottedcontents{subsubsection}[8.4em]{}{4.8em}{1pc}
\dottedcontents{subsubsubsection}[10.8em]{}{6.0em}{1pc}
\dottedcontents{subsubsubsubsection}[13.2em]{}{7.2em}{1pc}



\newcommand{\hreffn}[2]{\href{#1}{#2}\footnote{#1}}

\setlength{\parindent}{0pt}
\setlength{\parskip}{8pt}
\pagenumbering{gobble}



\renewcommand\maketitle{
    \begin{titlingpage}
        \begin{center}
            \includegraphics[width=\textwidth]{arch.png}\par\vspace{10em}
            {\huge \thetitle}\par\vspace{5em}
            {\LARGE \theauthor}\par\vspace{2.5em}
            {\large \thedate}\par
        \end{center}
    \end{titlingpage}
}
