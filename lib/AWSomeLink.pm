package AWSomeLink;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin;

our $my_self ;

# This method will run once at server start
sub startup {
  my $self = shift ;
  $my_self = $self ;

  # setup plugins
  $self->plugin('HTMLTags');
  $self->plugin('RenderFile');
  $self->app->secrets(['_4Ly#tBd^^kSG6QZD&r-jg54CD=CMx9!C#LscPcE?4q22s?wgG','^=QQbA%uN#p2%Z3&U&nsC^XfZK$U!RG7p&7jPRr53d+WUGX?9w']);
  # production or development
  $self->app->mode('development');
  #$self->app->mode('production');
  # ... just for hypnotoad
  $self->app->config(hypnotoad => {listen => ['http://127.0.0.1:3001']});
  #
  my $r = $self->routes;
  # General route
  $r->route('/:prefix/:controller/:action/*payload')->via('GET','POST')
    ->to(controller => 'initial', action => 'start', payload => undef, prefix => undef );
};

1;
