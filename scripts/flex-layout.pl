#!/usr/bin/perl

# todo: fxLayoutGap.lt-md fxFlex="60%" fxLayout.lt-md="column" fxLayout.lt-md="column" 

use strict;
use warnings;

my $component_preffix = shift @ARGV;

unless(defined $component_preffix)
{
    print STDERR "you must supply a component preffix\n";
    exit 1;
}

my $html = $component_preffix . ".html";
my $scss = $component_preffix . ".scss";
my $html_migrated = $component_preffix . ".flex.html";
my $scss_update = $component_preffix . ".flex.scss";

unless(-e $html || -e $
scss)
{
    print STDERR "file $html doesn't exist\n";
    exit 1;
}

open(HTML, "<", $html) or die "$!";
open(MIG, ">", $html_migrated) or die "$!";
open(SCSS, ">>", $scss) or die "$!";

my $css_class;
sub flex_insert_css {
        my $val = join '', @_;
        my $ext = "";
        $ext = '%' unless $val =~ /px$/;
$css_class = <<EOF;

.flex-flex-$val {
    \@include flex-flex($val$ext);
    max-height: $val$ext;
    max-width: $val$ext;
}
EOF
        print SCSS $css_class;
        return 1;
}

sub flex_insert_css_with_media_query {
        my ($q, $val) = @_;
        my $ext = "";
        $ext = '%' unless $val =~ /px$/;
$css_class = <<EOF;

.flex-flex-$q-$val {
    \@include fx-$q {
        \@include flex-flex($val$ext);
        max-height: $val$ext;
        max-width: $val$ext;
    }
}
EOF
        print SCSS $css_class;
        return 1;
}

sub gap_insert_css_with_media_query {
        my ($q, $val) = @_;
        my $ext = "";
        $ext = '%' unless $val =~ /px$/;
$css_class = <<EOF;

.flex-gap-$q-$val {
    \@include fx-$q {
        gap: $val$ext;
    }
}
EOF
        print SCSS $css_class;
        return 1;
}

# flex align
sub align_insert_css {
        my $val = join '', @_;
        if ((split ' ', $val) == 1) {
            return 0;
        }
        my $concat = $val;
        $concat =~ s/\s/\-/;
        my $align_items = "";
        $align_items = "\n\talign-items: center;" if $val =~ /center/;
$css_class = <<EOF;

.flex-align-$concat {
  \@include flex-align($val);$align_items
}
EOF
        print SCSS $css_class;
        return 1;
}

sub align_insert_css_with_media_query {
        my ($q, $val) = @_;
        my $concat = $val;
        $concat =~ s/\s/\-/;
        my $align_items = "";
        $align_items = "\n\t\t\t\talign-items: center;" if $val =~ /center/;
$css_class = <<EOF;

.flex-align-$concat-$q {
    \@include fx-$q {
        \@include flex-align($val);$align_items
    }
}
EOF
        print SCSS $css_class;
        return 1;
}

# warn about further investigation
my $warn = 0;
# flag if set mean we should include flex-layout file into css
my $include_flex = 0;
# media query pattern
my $mq = qr/[\w\-]*/;
# text property
my $tp = qr/[\w\-]*/;
# alphanumeric property
my $ap = qr/[\w\d\-]*/;
# css value
my $cv = qr/[\w\d\s%\-]*/;

while(my $line = <HTML>) {
    #fxLayout="x"
    $line =~ s/fxLayout="($tp)"/class="flex-$1"/g;
    #fxLayout.media-query="x"
    $line =~ s/fxLayout\.($mq)="($tp)"/class="flex-$2-$1"/g;
    #fxLayout="x wrap"
    $line =~ s/fxLayout="($tp) wrap"/class="flex-$1-wrap"/g;
    #fxLayout.media-query="x wrap"
    $line =~ s/fxLayout\.($mq)="($tp) wrap"/class="flex-$2-wrap-$1"/g;
    #fxHide
    $line =~ s/fxHide(?!\.)/class="flex-hide"/g;
    #fxHide.media-query
    $line =~ s/fxHide\.($mq)/class="flex-hide-$1"/g;
    #fxFlex
    $line =~ s/fxFlex(?!(=|\.))/class="flex-flex"/g;
    #fxLayoutGap="x"
    $line =~ s/fxLayoutGap(?!\.)="($cv)"/style="gap: $1;"/g;
    # the following rules required editing css classes
    # flex-flex-x
    $line =~ s/fxFlex="($ap)%"/fxFlex="$1"/g;
    if (my @grp = $line =~ /fxFlex(?!\.)="($cv)"/) {
        $line =~ s/fxFlex="($cv)"/class="flex-flex-$1"/g;
        my $ret = flex_insert_css(@grp);
        $include_flex = $ret if $include_flex == 0;
        
    }

    $line =~ s/fxFlex\.($mq)="($ap)%"/fxFlex\.$1="$2"/g;
    if (my @grp = $line =~ /fxFlex\.($mq)="($cv)"/) {
        $line =~ s/fxFlex\.($mq)="($cv)"/class="flex-flex-$2-$1"/g;
        my $ret = flex_insert_css_with_media_query(@grp);
        $include_flex = $ret if $include_flex == 0;
        
    }
    # flex-gap-x
    if (my @grp = $line =~ /fxLayoutGap\.($mq)="($ap)"/) {
        $line =~ s/fxLayoutGap\.($mq)="($ap)"/class="flex-gap-$2-$1"/g;
        my $ret = gap_insert_css_with_media_query(@grp);
        $include_flex = $ret if $include_flex == 0;
        
    }
    # flex-align-x
    if (my @grp = $line =~ /fxLayoutAlign="($cv)"/) {
        my $align = join('', @grp);
        $align =~ s/\s/\-/g;
        $line =~ s/fxLayoutAlign="($cv)"/class="flex-align-$align"/g;
        my $ret = align_insert_css(@grp);
        $include_flex = $ret if $include_flex == 0;
        
        $warn = 1;
    }
    if (my @grp = $line =~ /fxLayoutAlign\.($mq)="($cv)"/) {
        my $align = join('', $grp[1]);
        $align =~ s/\s/\-/g;
        $line =~ s/fxLayoutAlign\.($mq)="($cv)"/class="flex-align-$align-$1"/g;
        my $ret = align_insert_css_with_media_query(@grp);
        $include_flex = $ret if $include_flex == 0;
        
        $warn = 1;
    }

    print MIG $line;
}
close(SCSS);
close(HTML);
close(MIG);

# eliminate multiple classes and styles attr
open(MIG, "<", $html_migrated) or die "$!";
my $content = do { local $/; <MIG>};
# the emptyness
my $void = qr/[\s\n\t]*/;
# class prop
my $class = qr/[\w\d\-\s]*/;
# between classes
my $between_attr = qr/.*/;
# my $between_attr = qr/[\s\n\t"'\w\d=\[\]\(\)]*/;
while ($content =~ /class="($class)"($void)class="($class)"/g) {
    $content =~ s/class="($class)"($void)class="($class)"/class="$1 $3"/g;
}

while ($content =~ /class="($class)"($between_attr)class="($class)"/g) {
    $content =~ s/class="($class)"($between_attr)class="($class)"/class="$1 $3"$2/g;
}

# styles elimination
# style prop
my $style = qr/[\w\d\-\s:;]*/;
while ($content =~ /style="($style)"($void)style="($style)"/g) {
    $content =~ s/style="($style)"($void)style="($style)"/style="$1 $3"/g;
}

while ($content =~ /style="($style)"($between_attr)style="($style)"/g) {
    $content =~ s/style="($style)"($between_attr)style="($style)"/style="$1 $3"$2/g;
}
close(MIG);

# write the trimed result back
open(MIG, ">", $html_migrated) or die "$!";
print MIG $content;
close(MIG);

# prepend flex-layout import to the scss file
if ($include_flex) {
    open(SCSS_READ, "<", $scss) or die "$!";
    open(SCSS_UPDATE, ">", $scss_update) or die "$!";
    print SCSS_UPDATE "\@import '/src/theme/flex-layout.scss';\n";
    print SCSS_UPDATE $_ while <SCSS_READ>;
    close(SCSS_UPDATE);
    close(SCSS_READ);
    `mv $scss_update $scss`;
}

# apply html changes
`mv $html_migrated $html`;

# raise warning in case of flex-align class is used
# because it needs to be checked
print "warning: ", $component_preffix, " needs further investigation", "\n" if $warn;


