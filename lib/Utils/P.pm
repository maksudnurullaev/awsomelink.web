package Utils::P; {

=encoding utf8

=head1 NAME

    Different utilites 

=cut

use 5.012000;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Utils;
use Utils::User;
use MIME::Base64;
use Db;

sub post_add {
    my ($c,$db) = @_;
    if( !$c || !$db || !$db->is_valid ){
        warn "Variables not define properly to add new project!";
        return(undef);
    }
    my $data = Utils::validate($c,['title','project_id','password','password_confirmation'],['description']);
    return if ! Utils::validate_password2($c,$data->{password},$data->{password_confirmation});
    if( ! exists $data->{error} ){
        delete $data->{password_confirmation} ;
        if( !get_project_db_id($db,$data->{project_id}) ){
            return(1) if $db->insert($data) ;
        } else {
            $c->stash( "error_project_already_exist" => 1 );
        }
    }
    return(0)
};

sub post_properties {
    my ($c,$db) = @_;
    if( !$c || !$db || !$db->is_valid ){
        warn "Variables not define properly to add new project's property!";
        return(undef);
    }
    my $data = Utils::validate($c,['name','values']);
    if( ! exists $data->{error} ){
        return(1) if $db->insert($data) ;
    }
    return(0)
};

sub post_recipients {
    my ($c,$db) = @_;
    if( !$c || !$db || !$db->is_valid ){
        warn "Variables not define properly to add new project's recipient!";
        return(undef);
    }
    my $data = Utils::validate($c,['name','email','password']);
    if( ! exists $data->{error} ){
        return(1) if $db->insert($data) ;
    }
    return(0)
};

sub post_recipients_update {
    my ($c,$db,$id) = @_;
    if( !$c || !$db || !$db->is_valid || !$id ){
        warn "Variables not define properly to update project's recipient!";
        return(undef);
    }
    my $data = Utils::validate($c,['id','name','email','password']);
    if( ! exists $data->{error} ){
        return(1) if $db->del($id) && $db->insert($data) ;
    }
    return(0)
};

sub post_properties_update {
    my ($c,$db,$id) = @_;
    if( !$c || !$db || !$db->is_valid || !$id ){
        warn "Variables not define properly to update project's property!";
        return(undef);
    }
    my $data = Utils::validate($c,['id','name','values']);
    if( ! exists $data->{error} ){
        return(1) if $db->del($id) && $db->insert($data) ;
    }
    return(0)
};

sub post_update{
    my ($c,$db) = @_;
    if( !$c || !$db || !$db->is_valid ){
        warn "Variables not define properly to add new project!";
        return(undef);
    }

    my $data = Utils::validate($c,['id','object_name','title'],['description']);
    if( !exists $data->{error} ){
        if( $db->update($data) ){
            $c->stash( "success_updated" => 1 );
            return(1);
        } else {
            $c->stash( "error_updated" => 1 );
        }
    }
    return(0)
};

sub get_project_db_id{
    my($db,$project_id) = @_;
    if( !$db || !$project_id || !$db->is_valid ){
        warn "Variables not define properly to detect project existance!";
        return(undef);
    }
    my $objects = $db->get_objects({name=>['project'],add_where=>"value='$project_id'"});
    if( $objects ){
        my @keys = keys %{$objects};
        return(undef) if scalar(@keys) == 0;
        return($keys[0]) if scalar(@keys) == 1;
        warn "Many objects with same project id: $project_id";
    }
    return(undef);
};

sub change_password{
    my ($c,$db,$prefix) = @_;
    if( !$c || !$db || !$prefix || !$db->is_valid ){
        warn "Variables not define properly to change project's password!";
        return(undef);
    }

    # 1. check mandatory fields
    my $data = Utils::validate($c,['old_password','new_password','new_password_confirmation'], ['id','object_name','project_id']);
    return if exists $data->{error} ;
    # 2. validate new password 
    return if ! Utils::validate_password2($c,$data->{new_password},$data->{new_password_confirmation});
    # 3. check old password
    if( ! Utils::User::authorized($db,$prefix,$data->{old_password}) ){
        $c->stash( "invalid_password" => 1 );
        return;
    }
    return if exists $data->{error} ;
    # 4. update to new password
    my $new_data = {
        id => $data->{id},
        object_name => $data->{object_name},
        password => $data->{new_password}
    };
    if( $db->update($new_data) ){
        $c->stash( "success_updated" => 1 );
    } else {
        $c->stash( "error_updated" => 1 );
    }
};

sub post_files{
    my($c,$prefix) = @_;
    if( !$c || !$prefix ){
        warn "Variables not define properly save project files!";
        return(undef);
    }
    my $file = $c->param('file_0');
    my $file_found = 0;
    if( $file && $file->filename ){
        my $path_file = get_files_path($c,$prefix) . '/' . $file->filename;
        $file->move_to($path_file);
        $file_found++;
    }
    for my $file_name ($c->param){
        if( $file_name =~ /screenshot/ ){
            my $value = $c->param($file_name);
            my $header = substr($value, 0, 50);
            my $indx = index $header, ',';
            if( $indx != -1 && $header =~ /^data:image/ ){
                my $file_data = decode_base64 substr($value,$indx+1);
                my $path_file = get_files_path($c,$prefix) . '/' . $file_name;
                open(my $fh, '>:raw', $path_file);
                print $fh $file_data;
                close $fh;
                $file_found++;
            }
        }
    }
    $c->stash( "invalid_file" => 1 ) if ! $file_found ;
    return;
};

sub get_files_path{
    my($c,$prefix) = @_;
    if( !$c || !$prefix ){
        warn "Variables not define properly get project files path!";
        return(undef);
    }
    my $folder = "FILES/$prefix/FILES";
    my $path = $c->app->home->rel_dir($folder);
    system "mkdir -p '$path/'" if ! -d $path ;
    return($path);
};

# END OF PACKAGE
};

1;

__END__

=head1 AUTHOR

    M.Nurullaev <maksud.nurullaev@gmail.com>

=cut
