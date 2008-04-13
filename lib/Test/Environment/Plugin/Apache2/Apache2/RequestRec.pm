package Test::Environment::Plugin::Apache2::Apache2::RequestRec;

1;

package Apache2::RequestRec;

=head1 NAME

Test::Environment::Plugin::Apache2::Apache2::RequestRec - fake Apache2::RequestRec for Test::Environment

=head1 SYNOPSIS

    use Test::Environment qw{
        Apache2
    };
    
    my $request = Apache2::RequestRec->new(
        'headers_in' => {
            'Accept-Encoding' => 'xyz,gzip'
        },
        'hostname' => 'with.the.man.sk',
        'uri'      => '/index.html',
        'args'     => 'id=me',
    );
    is(
        My::App:Apache2::Index::handler($request),
        Apache2::Const::REDIRECT,
    );
    is(
        $request->headers_out->get('Location'),
        'http://with.the.man.sk/me/',
    );

=head1 DESCRIPTION

Will populate Apache2::RequestRec namespace with fake methods that can be used for
testing.

=cut

use warnings;
use strict;

our $VERSION = '0.01';

use APR::Pool;
use APR::Table;

use base 'Class::Accessor::Fast';


=head1 PROPERTIES

    hostname
    uri
    apr_pool
    args
    get_server_port
    dir_config

=cut

__PACKAGE__->mk_accessors(qw{
    hostname
    uri
    apr_pool
    args
    get_server_port
    dir_config
});


=head1 METHODS

=head2 new()

Object constructor.

=cut

sub new {
    my $class = shift;
    my $self = $class->SUPER::new({
        'get_server_port' => 80,
        'apr_pool'    => APR::Pool->new,
        @_,
    });
    
    # initialize all apr tables
    foreach my $apt_table_name (qw(apr_table headers_in headers_out subprocess_env dir_config)) {
        $self->{$apt_table_name} = APR::Table::make($self->apr_pool, 100)
            if not defined $self->{$apt_table_name};
    }
    
    return $self;
}

=head2 pnotes

Get/Set pnote.

=cut

sub pnotes {
    my $self      = shift;
    my $note_name = shift;
    
    if (@_ > 0) {
        $self->{'pnotes'}->{$note_name} = shift;
    }
    
    return $self->{'pnotes'}->{$note_name};
}

=head2 APR::Table methods

=head3 apt_table()
=head3 subprocess_env()
=head3 headers_in()
=head3 headers_out()
=head3 dir_config()

=cut

sub apr_table      { return shift->_get_set('apr_table',      @_) };
sub subprocess_env { return shift->_get_set('subprocess_env', @_) };
sub headers_in     { return shift->_get_set('headers_in',     @_) };
sub headers_out    { return shift->_get_set('headers_out',    @_) };
sub dir_config     { return shift->_get_set('dir_config',     @_) };

sub _get_set {
    my $self = shift;
    my $name = shift;
   
    if (@_ > 0) {
        my $key_name = shift;
        if (@_ > 0) {
            $self->{$name}->add($key_name => shift);
        }
        return $self->{$name}->get($key_name);
    }
    else {
        return $self->{$name};
    }
}


=head2 Apache2::Filter::r

just calls $self->request_rec(@_);

=cut

sub Apache2::Filter::r {
    my $self   = shift;
    $self->request_rec(@_);
}


=head2 Apache2::Filter::request_rec

Returns Apache2::RequestRec.

=cut

sub Apache2::Filter::request_rec {
    my $self   = shift;
    
    if (@_ > 0) {
        $self->{'request_rec'} = shift;
    }
    
    if (ref $self->{'request_rec'} ne __PACKAGE__) {
        $self->{'request_rec'} = bless $self->{'request_rec'}, __PACKAGE__;
    }
    
        
    return $self->{'request_rec'};
}


'writing on the wall';

__END__

=head1 AUTHOR

Jozef Kutej

=cut