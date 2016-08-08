package Asr::Schema::Result::Tag;

use Modern::Perl;
use base 'DBIx::Class::Core';

use Data::FormValidator;

__PACKAGE__->load_components(qw'Helper::Row::ToJSON Validation');

__PACKAGE__->table('tag');
__PACKAGE__->validation(
   module => 'Data::FormValidator',
   auto => 0,
   filter => 0,
   profile => {
      required => [qw/name/]
   }
);
__PACKAGE__->add_columns(
   'id' => {
      data_type => 'integer',
      is_auto_increment => 1,
      is_nullable => 0
   },
   'name' => {
      data_type => 'varchar',
      is_nullable => 0
   },
   'info' => {
      data_type => 'varchar',
      size => 128,
      is_nullable => 1
   },
   'created' => {
      data_type => 'timestamp',
      is_nullable => 0,
      retrieve_on_insert => 1
   },
   'modified' => {
      data_type => 'timestamp',
      is_nullable => 0,
      retrieve_on_insert => 1
   }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraints(
   tag_name_key => [qw/name/]
);
__PACKAGE__->has_many(ush => 'Asr::Schema::Result::UserSiteHourly', {
   'foreign.tag_id' => 'self.id'
});

1;
