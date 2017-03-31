package Asr::Schema;

use Modern::Perl;
use base 'DBIx::Class::Schema';

use DBIx::Error;

__PACKAGE__->exception_action(DBIx::Error->exception_action);
__PACKAGE__->load_namespaces();

1;

