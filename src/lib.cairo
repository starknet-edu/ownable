#[contract]
mod Ownable {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    #[event]
    fn OwnershipTransferred(previous_owner: ContractAddress, new_owner: ContractAddress) {}

    struct Storage {
        owner: ContractAddress,
    }

    #[constructor]
    fn constructor() {
        let deployer = get_caller_address();
        owner::write(deployer);
    }

    #[view]
    fn get_owner() -> ContractAddress {
        owner::read()
    }

    #[external]
    fn transfer_ownership(new_owner: ContractAddress) {
        only_owner();
        let previous_owner = owner::read();
        owner::write(new_owner);
        OwnershipTransferred(previous_owner, new_owner);
    }

    fn only_owner() {
        let caller = get_caller_address();
        assert(caller == owner::read(), 'Caller is not the owner');
    }
}
