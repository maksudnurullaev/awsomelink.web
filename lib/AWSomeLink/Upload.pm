package AWSomeLink::Upload; {

=encoding utf8

=head1 NAME

    Upload controller

=cut

use Mojo::Base 'Mojolicious::Controller';
use Utils;
use Utils::R;
use Data::Dumper;

sub start{
    my $self = shift;
    my $prefix = Utils::trim $self->stash->{prefix};
    # 1. Check path for LinkID 
    my $folder = "FILES/$prefix/FILES";
    my $path = $self->app->home->rel_dir($folder);
    system "mkdir -p '$path/'" if ! -d $path ;
    # 2. Save all files
    for my $upload (@{$self->req->uploads}){
        my $path_file = "$path/" . $upload->filename;
        $upload->move_to($path_file);
    }
};

sub meta{
    my $self = shift;
    my $prefix = Utils::trim $self->stash->{prefix};
    # 1. Check path for LinkID 
    my $folder = "FILES/$prefix";
    my $path = $self->app->home->rel_dir($folder);
    system "mkdir -p '$path/'" if ! -d $path ;
    # 2. Save all files
    for my $upload (@{$self->req->uploads}){
        my $path_file = "$path/" . $upload->filename;
        $upload->move_to($path_file);
        warn $path_file ;
    }
    Utils::sync_meta($path);
};

sub download{
    my $self = shift;
    my $prefix = Utils::trim $self->stash->{prefix};
    my $filename = $self->stash('payload');
    my $folder = "FILES/$prefix/FILES";
    my $path_file = $self->app->home->rel_file("$folder/$filename");
    # check that file belongs to issue
    my $issue_id = $self->param('issue');
    if( $issue_id ){
        $folder = Utils::R::get_files_path($self,$issue_id);
        $path_file = "$folder/$filename";
    }
    if( -e $path_file ){
        $self->render_file('filepath' => $path_file, 'filename' => $filename);
    } else {
        warn "File not found to download!" ;
    } 
}

# END OF PACKAGE
};

1;

__END__

=head1 AUTHOR

    M.Nurullaev <maksud.nurullaev@gmail.com>

=cut
