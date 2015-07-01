package Utils::R; {

=encoding utf8

=head1 NAME

    Different utilites 

=cut

use 5.012000;
use strict;
use warnings;
use utf8;
use Utils;
use Db;
use MIME::Base64;
use Data::Dumper;

sub attach_properties{
    my ($c,$data) = @_ ;
    for my $param ($c->param){
        if( $param !~ /^[file|screenshot|payload|prefix]/ ){
            my $temp = $c->param($param) ;
            $data->{$param} = Utils::trim $temp ;
        }
    }
};

sub get_files_path{
    my($c,$issue_id) = @_;
    if( !$c || !$issue_id ){
        warn "Variables not define properly get issue's files path!";
        return(undef);
    }
    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $subfolder = substr $issue_id, -8 ;
    my $folder = "FILES/$prefix/FILES/$subfolder";
    my $path = $c->app->home->rel_dir($folder);
    system "mkdir -p '$path/'" if ! -d $path ;
    return($path);
};

sub get_files_count{
    my($c,$issue_id) = @_;
    if( !$c || !$issue_id ){
        warn "Variables not define properly get issue's files count!";
        return(undef);
    }
    my $path = get_files_path($c,$issue_id);
    return(0) if ! -d $path ;
    my @files = <"$path/*">;
    my $result = 0 ;
    for my $file (@files ){ $result++ if ! -d $file ; }
    return( $result );
};

sub get_files_info{
    my($c,$issue_id) = @_;
    if( !$c || !$issue_id ){
        warn "Variables not define properly get issue's files count!";
        return(undef);
    }
    my $path = get_files_path($c,$issue_id);
    return(undef) if ! -d $path ;
    my $result = Utils::get_files_formated_info($path);
    $c->stash( _result => $result );
    return($result);
};

sub get_confirmations_total{
    my($c,$confirmations) = @_ ;
    my($_pos,$_neg) = (0,0);
    my %h = split /[;,]/, $confirmations ;
    for my $key (keys %h){
        if( $h{$key} ){
            $_pos++;
        } else {
            $_neg++;
        }
    }
    my $result = '';
    $result = '+' . $_pos if $_pos ;
    $result =  $result . ($_pos?' | ':'') . '-' . $_neg if $_neg ;
    return($result);
};

sub post_files{
    my($c,$issue_id) = @_;
    if( !$c || !$issue_id ){
        warn "Variables not define properly save project files!";
        return(undef);
    }
    my $file = $c->param('file_0');
    my $file_count = 0;
    if( $file && $file->filename ){
        my $path_file = get_files_path($c,$issue_id) . '/' . $file->filename;
        $file->move_to($path_file);
        $file_count++;
    }
    for my $file_name ($c->param){
        if( $file_name =~ /screenshot/ ){
            my $value = $c->param($file_name);
            my $header = substr($value, 0, 50);
            my $indx = index $header, ',';
            if( $indx != -1 && $header =~ /^data:image/ ){
                my $file_data = decode_base64 substr($value,$indx+1);
                my $path_file = get_files_path($c,$issue_id) . '/' . $file_name;
                open(my $fh, '>:raw', $path_file);
                print $fh $file_data;
                close $fh;
                $file_count++;
            }
        }
    }
    return($file_count);
};

sub issue_add {
    my ($c,$db) = @_;
    if( !$c || !$db || !$db->is_valid ){
        warn "Variables not define properly to add new issue!";
        return(undef);
    }
    my $data = Utils::validate($c,['description']);
    if( ! exists $data->{error} ){
        attach_properties $c, $data ;
        $data->{owner} = $c->session('user id');
        my $issue_id = $db->insert($data);
        post_files($c,$issue_id) if $issue_id;
        return(1);
    }
    return(0)
};

sub issue_edit {
    my ($c,$db,$dbobject_id) = @_;
    if( !$c || !$db || !$db->is_valid ){
        warn "Variables not define properly to add new issue!";
        return(undef);
    }
    my $data = Utils::validate($c,['id','description','issue_status']);
    if( ! exists $data->{error} ){
        attach_properties $c, $data ;
        $data->{owner} = $c->session('user id');
        my $issue_id = $db->update($data);
        post_files($c,$issue_id) if $issue_id;
        return(1);
    }
    return(0)
};

sub check_rw_access {
    my ($db,$dbobject_id,$user_id) = @_;
    if( !$db || !$db->is_valid || !$dbobject_id || !$user_id ){
        warn "Variables not define properly to check user access!";
        return(0);
    }
    my $where_part = { name => ['issue'], id => [$dbobject_id], field => ['owner'], value => [$user_id] } ;
    return( $db->get_counts($where_part) );
};

sub issue_confirm{
    my($c,$db,$dbobject_id,$confirm) = @_ ;
    if( !$c || !$db || !$dbobject_id ){
        warn "Variables not define properly to confirm issue!" ;
        return(undef);
    }
    my $dbobjects = $db->get_objects({ id => [$dbobject_id] });
    return if ! exists $dbobjects->{$dbobject_id} ; 
    
    my $o = $dbobjects->{$dbobject_id};
    my $confirmations = exists($o->{confirmations}) ?
        $o->{confirmations}  : '' ;
    $confirm = $confirm ? 1 : 0 ;
    my $user_id = $c->session('user id');
    if( $confirmations ){
        my %h = split /[;,]/, $confirmations ;
        $h{$user_id} = $confirm  ;
        $confirmations = join(";", map { "$_,$h{$_}" } keys %h);
    } else {
        $confirmations = "$user_id,$confirm";
    }
    my $data = { object_name => $o->{object_name} ,
                 id => $o->{id} ,
                 confirmations => $confirmations };
    $db->update($data) ;             
};


# END OF PACKAGE
};

1;

__END__

=head1 AUTHOR

    M.Nurullaev <maksud.nurullaev@gmail.com>

=cut
