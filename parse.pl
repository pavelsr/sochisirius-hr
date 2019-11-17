use strict;
use warnings;
use utf8;
use feature 'say';

use Mojo::DOM;
use Mojo::UserAgent;
use Text::CSV;
use Data::Dumper::AutoEncode;

my $ua = Mojo::UserAgent->new;
my $csv = Text::CSV->new ({ quote => '"', auto_diag => 1 });
my $filename = 'demo.csv';
my $start_smena_number = 386; # определено эмпирически, вначале установив = 1 и посмотрев итоговый csv

sub fix_html_string {
    my ($html_str) = @_;
    my $str = $html_str;
    $str =~ s/[\r\n\t]+//g;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    return $str;
}

# accept string and return array of hashed (fio, region)
# признак fio - строка с запятой
# https://regex101.com/r/I6fRdS/3

sub parse_childrens {
    my ($str) = @_;
    my @result;
    my @arr = split( "\n", $str );
    for my $x (@arr) {
        # my $comma_num = scalar split( ',', $x );
		# my $dots_num = scalar split( '.', $x )
		my $comma_num = $x =~ tr/\,//;
		my $dots_num = $x =~ tr/\.//;
		
        if ( ( $x =~ /^.+\,.+$/ ) && ( $comma_num == 1 ) && ( $dots_num == 0 ) ) {
            my @fio_rgn = split( ',', $x );
            push @result, {
                fio    => $fio_rgn[0],
                region => $fio_rgn[1],
            };
        }
    }
    return \@result;
}

# Return Mojo::DOM object or die
sub get_url_dom_or_die {
    my ( $url, $css ) = @_;
    my $tx = $ua->get($url);

    if ( my $err = $tx->error ) {
        if ( $err->{code} == 404 ) {
            return;
        }
        else {
            die "Transaction error: " . $url . " : " . $err->{code} . ' ' . $err->{message};
        }
    }
    if ( $tx->res->is_success ) {
        if ($css) {
            my $dom = $tx->res->dom->at($css);

            # if ( defined $dom ) {
            if ( ref($dom) eq 'Mojo::DOM' ) {
                return $dom;
            }
        }
        else {
            return $tx->res->dom;
        }

        #return $tx->res->dom;
        # return $tx->res->json; # in case of API
    }
    else {
        die "Error accessing url : " . $tx->req->url->to_abs . ", error: " . $tx->res->error->{message};
    }
}

sub text_if_exists {
	my ( $dom, $css ) = @_;
	if ( $dom->at($css) ) {
		return $dom->at($css)->all_text; # or ->text
	}
	return;
}

# /obuchenie/project/smena400
my $last_url          = get_url_dom_or_die( 'https://sochisirius.ru/obuchenie/project', 'div.education__box.expired' )->at('a.education__linkmore')->attr('href');
my $last_smena_number = ( split( 'smena', $last_url ) )[1];

my $base = 'https://sochisirius.ru/obuchenie/project/smena';
open my $fh, ">:encoding(utf8)", $filename or die "$filename: $!";

for ( my $i = $last_smena_number; $i >= $start_smena_number; $i-- ) {

    my $data = {};
    my $data->{url} = $base . $i;

	say $data->{url};
    my $dom = get_url_dom_or_die( $data->{url} );

    if (defined $dom) {

        # $data->{smena_date}     = fix_html_string( $dom->at('div.header-block.text-center span.smena__date')->text );
        # $data->{smena_name}     = $dom->at('div.header-block.text-center h1')->text;
        # $data->{childrens_text} = $dom->at('div#tab-content-container div.col-1.paragraph-m-0')->all_text;
        # $data->{childrens}      = parse_childrens( $data->{childrens_text} );
		
		    $data->{smena_date}     = text_if_exists( $dom, 'div.header-block.text-center span.smena__date' );
        $data->{smena_name}     = text_if_exists( $dom, 'div.header-block.text-center h1' );
        $data->{childrens_text} = text_if_exists( $dom, 'div#tab-content-container div.col-1.paragraph-m-0' );
        $data->{childrens}      = parse_childrens( $data->{childrens_text} );

        delete $data->{childrens_text};
		
		# write to csv
		for my $x ( @{$data->{childrens}} ) {
			
			my @row = (
				fix_html_string($x->{fio}),
				fix_html_string($x->{region}),
				fix_html_string($data->{smena_name}),
				fix_html_string($data->{smena_date}),
				$data->{url},
			);
			
			$csv->say ($fh, \@row);
		}
		
		#$csv->say ($fh, $_) for @rows;

        # say $data->{url};
        # say $data->{smena_date};
        # say $data->{smena_name};
        # say $data->{childrens_text};
        # say "======================"

        warn eDumper $data;
    }
}

close $fh or die "$filename: $!";
