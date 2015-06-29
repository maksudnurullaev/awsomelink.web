package Utils::Excel; {

=encoding utf8
=head1 NAME
    Excel utilites 
=cut

use 5.012000;
use strict;
use warnings;
use utf8;
use Utils;
use Spreadsheet::WriteExcel;
use Db;
use Data::Dumper ;

sub get_new_file_path_name{
    my $uuid = Utils::get_uuid();
    my $file_name = "awsome_export_$uuid.xls" ;
    my $file_path = "/tmp/$file_name" ;
    return(($file_path,$file_name));
};

sub export{
    my $c = shift ;

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;
    my $issues = Utils::get_db_objects_filtered($db,'issue',$c->session('issues filter')) ;
    my $owners = Utils::get_db_objects_filtered($db,'recipient');

    my ($file_path,$file_name) = get_new_file_path_name();

    # Create a new workbook 
    my $workbook  = Spreadsheet::WriteExcel->new($file_path);
    my $bold = $workbook->add_format(bold => 1);
    # Add worksheet
    my $worksheet = $workbook->add_worksheet('Issues - AWSome.Link');
    $worksheet->set_column('A:A', 30);
    # check for data
    if( !$issues || !keys(%{$issues}) ){
        $workbook->close();
        return(($file_path,$file_name));
    }
    # Insert data
    my ($ord_row,$ord_col) = (0,0);
    my @issue_ids = keys($issues);
    # Add headers
    # ... defaults headers
    $worksheet->write($ord_row,$ord_col++,'DESCRIPTION');
    $worksheet->write($ord_row,$ord_col++,'LINK');
    $worksheet->write($ord_row,$ord_col++,'STATUS');
    $worksheet->write($ord_row,$ord_col++,'CREATED BY');
    $worksheet->write($ord_row,$ord_col++,'E-MAIL');
    # ... other headers
    for my $header ( sort keys %{$issues->{$issue_ids[0]}} ){
         if ( $header !~ /(id|description|issue_status|object_name|owner)/ ){
            $worksheet->write($ord_row,$ord_col++,uc($header));
         }
    }
    # Add data rows
    for my $id (@issue_ids){
        $ord_row++;
        $ord_col = 0;
        my $o = $issues->{$id};
        my $owner = $owners->{$o->{owner}};
        $worksheet->write($ord_row,$ord_col++,$o->{description});
        $worksheet->write_url($ord_row,$ord_col++,"https://awsome.link/$prefix/r/issues_edit/$id",'link');
        $worksheet->write($ord_row,$ord_col++,$o->{issue_status});
        $worksheet->write($ord_row,$ord_col++,$owner->{name});
        $worksheet->write($ord_row,$ord_col++,$owner->{email});
        for my $property (sort keys %{$o}){
            if ( $property !~ /(id|description|issue_status|object_name|owner)/ ){
                $worksheet->write($ord_row,$ord_col++,$o->{$property});
            }
        }
    }
    # final
    $workbook->close();
    return(($file_path,$file_name));
};


# END OF PACKAGE
};

1;

__END__

=head1 AUTHOR
 M.Nurullaev <maksud.nurullaev@gmail.com>
=cut
