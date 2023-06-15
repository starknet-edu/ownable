use array::ArrayTrait;
use result::ResultTrait;
use cheatcodes::RevertedTransactionTrait;

fn setup(deployer_address: felt252) -> felt252 {
    let class_hash = declare('ownable').unwrap();
    let constructor_args = ArrayTrait::new();
    let prepared = prepare(class_hash, @constructor_args).unwrap();

    start_prank(deployer_address, prepared.contract_address);
    let contract_address = deploy(prepared).unwrap();
    stop_prank(contract_address);

    return contract_address;
}

#[test]
fn test_deployer_is_owner() {
    let deployer_address = 123;
    let contract_address = setup(deployer_address);

    let function_args = ArrayTrait::new();
    let returned = call(contract_address, 'get_owner', @function_args).unwrap();
    let owner_address = *returned.at(0_u32);

    assert(owner_address == deployer_address, 'The owner is not the deployer');
}

#[test]
fn test_owner_can_transfer_ownership() {
    let deployer_address = 123;
    let contract_address = setup(deployer_address);

    let new_owner = 456;
    let mut function_args = ArrayTrait::new();
    function_args.append(new_owner);

    start_prank(deployer_address, contract_address);
    invoke(contract_address, 'transfer_ownership', @function_args);
    stop_prank(contract_address);

    let function_args = ArrayTrait::new();
    let returned = call(contract_address, 'get_owner', @function_args).unwrap();
    let contract_owner = *returned.at(0_u32);
    
    assert(contract_owner == new_owner, 'Ownership was not transferred');
}

#[test]
fn test_only_owner_can_transfer_ownership() {
    let deployer_address = 123;
    let contract_address = setup(deployer_address);

    let hacker = 456;
    let mut function_args = ArrayTrait::new();
    function_args.append(hacker);

    start_prank(hacker, contract_address);
    match invoke(contract_address, 'transfer_ownership', @function_args) {
        Result::Ok(x) => assert(false, 'Should not transfer ownership'),
        Result::Err(x) => assert(x.first() == 'Caller is not the owner', 'Incorrect error message'),
    };
    stop_prank(contract_address);
}