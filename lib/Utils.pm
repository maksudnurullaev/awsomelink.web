package Utils; {

=encoding utf8

=head1 NAME

    Different utilites 

=cut

use 5.012000;
use strict;
use warnings;
use utf8;
use File::stat;
use File::Basename;
use POSIX 'strftime';

use Cwd;
use Time::Piece;
use Data::UUID;
use File::Spec;
use File::Path qw(make_path);
use Locale::Currency::Format;
use Data::Dumper;

sub trim{
    my $string = $_[0];
    if(defined($string) && $string){
        $string =~ s/^\s+|\s+$//g;
        return($string);
    }
    return(undef);
};

sub trim_array{
    my $arr = shift ;
    for my $e (@{$arr}){
        $e = trim($e);
    }
};

sub validate{
    my ($c,$mandatories,$optionals) = @_;
    my $data = { object_name => $c->param('object_name') };
    for my $field (@{$mandatories}){
        $data->{$field} = Utils::trim $c->param($field);
        if ( !$data->{$field} ){
            if( ! exists $data->{error} ) {
                $data->{error} = 1 ;
                $c->stash( "error_empty" => 1 );
            }
            $c->stash(($field . '_validation') => 'has-error');
        } else {
            $c->stash(($field . '_validation') => 'has-success');
        }
    }
    for my $field (@{$optionals}){
        $data->{$field} = $c->param($field) if $c->param($field);
    }
    return($data);
};

sub validate_password2{
    my ($c,$password1,$password2) = @_ ;
    if ( length($password1) < 4 
            || $password1 ne $password2 ){
        $c->stash( "error_password" => 1 );
        return(0);
    }
    return(1);
};

sub validate_password3{
    my ($password1, $password2, $old_password) = @_;
    return(0) if ( length($password1) < 4 )
        || ($password1 ne $password2) ;
    return(1) if !$old_password ;
    return( $old_password ne $password1 );
};

sub validate_email{
    my $email = shift;
    return($email =~ /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/) if $email;
    return;
};

sub shrink_if{
    my $self = shift;
    my $string = shift;
    my $length = shift;
    return(undef) if !$string;
    return (substr($string,0,$length) . '...') if length($string) > (5+$length);
    return($string);
};

sub get_files{
    my ($c,$prefix) = @_ ;
    return(undef) if !$c || !$prefix ;
    my $path = $c->app->home->rel_dir("FILES/$prefix/FILES");
    return(undef) if ! -d $path ;
    return(get_files_formated_info($path));
};

sub get_files_formated_info{
    my $path = shift;
    my @files = <"$path/*">;
    my $result = {};
    for my $file (@files ){
        next if -d $file ;
        my($filename, $dirs, $suffix) = fileparse($file);
        my $st = stat($file);
        $result->{$filename} = { size => $st->[7], mdate => strftime('%Y-%m-%d %H:%M:%S', localtime( $st->[9])) } ;
    }
    return( $result );
};

sub get_files_count{
    my ($c,$prefix) = @_ ;
    return(undef) if !$c || !$prefix ;
    my $path = $c->app->home->rel_dir("FILES/$prefix/FILES");
    return(0) if ! -d $path ;
    my @files = <"$path/*">;
    my $result = 0 ;
    for my $file (@files ){ $result++ if ! -d $file ; }
    return( $result );
};

sub get_dbobjects_count{
    my ($c,$prefix,$name) = @_ ;
    if( !$c || !$prefix ){
        warn "Variables not define properly to detect db objects count!";
        return(0);
    }
    my $db = Db->new($c,$prefix) ;
    my $properties = $db->get_objects( { name => [$name] } );
    return(0) if ! $properties ;
    return(scalar(keys(%{$properties}))) ;
};

sub sync_meta{
    my $path = shift;
    my $meta_file = "$path/META.TXT";
    my $files_dir = "$path/FILES";
    if( !$path || (! -d $path) || (! -e $meta_file) || (! -d $files_dir) ){
        warn "Some path are not defined or not exist!";
        return;
    }
    # 1. Make hash from existance meta file
    if( open my $info, $meta_file ){
        my @lines = <$info>;
        close($info);
        my $content ;
        for (@lines){
            s/\R\z// ;
            $content .= $_ if $_ ;
        }
        if( opendir(my $dir, $files_dir) ){
            while( readdir $dir ){
                if( $_ ne '.' && $_ ne '..' ){
                    if( index($content,$_) == -1 ){
                        unlink "$files_dir/$_";
                    }
                }
            }
        } else {
            warn "Could not open $files_dir!";
        }
    } else {
        warn "Could not open $meta_file!";
    }
};

sub get_uuid{
    my $ug = new Data::UUID;
    my $uuid = $ug->create;
    my @result = split('-',$ug->to_string($uuid));
    return(lc($result[0]));
};

sub get_date_uuid{
    my $result= Time::Piece->new->strftime('%Y.%m.%d %T ');
    return($result . get_uuid());
};

sub deploy_db_object_all{
    my ($c,$dbc,$id,$prefix,$params) = @_ ;
    return(0) if !$dbc || !$id ;

    my $_params = { id => [$id] };
    if( $params ){
        for my $key( keys %{$params} ){
            $_params->{$key} = $params->{$key} ;
        }
    }
    my $objects = $dbc->get_objects( $_params );
    if( $objects && exists($objects->{$id}) ){
        my $object = $objects->{$id};
        for my $key (keys %{$object}){
            if( $prefix ){
                $c->stash("$prefix.$key" => $object->{$key});
            } else {
                $c->stash($key => $object->{$key});
            }
        }
        return($object);
    }
    return(undef);
};

sub deploy_db_object{
    my($c,$db,$dbobject_id) = @_;
    if( !$c || !$db || !$dbobject_id || !$db->is_valid ){
        warn "Variables not define properly to detect project existance!";
        return(0);
    }
    my $objects = $db->get_objects( { id => [$dbobject_id] } );
    if( $objects && exists( $objects->{$dbobject_id} ) ){
        my $object = $objects->{$dbobject_id};
        for my $key (keys %{$object}){
            if( $key !~ /password/ ){ 
                $c->stash($key => $object->{$key});
            }
        }
    } else {
        warn "Db object with id: '$dbobject_id' not exist!" ;
        $c->stash( "error_dbobject_not_exist" => 1 );
    }
};

sub deploy_db_objects{
    my($c,$db,$name,$names) = @_;
    if( !$c || !$db || !$db->is_valid || !$name || !$names ){
        warn "Variables not define properly deploy project related onbjects!";
        return(undef);
    }
    $c->stash( $names => $db->get_objects( { name => [$name] } ) ) ;
};

# END OF PACKAGE
};

1;

__END__

=head1 AUTHOR

    M.Nurullaev <maksud.nurullaev@gmail.com>

=cut
