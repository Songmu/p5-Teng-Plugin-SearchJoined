use strict;
use warnings;
use utf8;
use Test::More;
use t::Utils;
use Mock::BasicJoin;

Mock::BasicJoin->load_plugin('SearchJoined');

my $dbh = t::Utils->setup_dbh;
my $db = Mock::BasicJoin->new({dbh => $dbh});
$db->prepare_db($dbh);

isa_ok $db, 'Teng';
isa_ok $db, 'Mock::BasicJoin';

$db->bulk_insert(user => [{
    id   => 1,
    name => 'aaa',
}, {
    id   => 2,
    name => 'bbb',
}]);

$db->bulk_insert(item => [{
    id   => 1,
    name => 'aaa_item',
}, {
    id   => 2,
    name => 'bbb_item',
}]);

$db->bulk_insert(user_item => [{
    user_id => 1,
    item_id => 1,
}, {
    user_id => 1,
    item_id => 2,
}, {
    user_id => 2,
    item_id => 2,
}]);

subtest 'bind_named' => sub {
    my $itr = $db->search_joined_named(q[
        SELECT * FROM user_item
        INNER JOIN user
            ON user_item.user_id = user.id
        WHERE user.id = :user_id
        ORDER BY :order
    ], { user_id => 1, order => 'user_item.item_id' });
    isa_ok $itr, 'Teng::Plugin::SearchJoined::Iterator';

    my $count = 0;
    while (my ($user_item, $user) = $itr->next) {
        isa_ok $user_item, 'Mock::BasicJoin::Row::UserItem';
        isa_ok $user,      'Mock::BasicJoin::Row::User';
        ok $user->name, 'aaa';
        $count++;
    }
    is $count, 2;
};

done_testing;
