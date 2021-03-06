use clap::{App, ArgMatches, SubCommand};

use casper_node::rpcs::{account::PutDeploy, RpcWithParams};

use super::creation_common::{self, DisplayOrder};
use crate::{command::ClientCommand, common, RpcClient};

impl RpcClient for PutDeploy {
    const RPC_METHOD: &'static str = Self::METHOD;
}

impl<'a, 'b> ClientCommand<'a, 'b> for PutDeploy {
    const NAME: &'static str = "put-deploy";
    const ABOUT: &'static str = "Creates a new deploy and sends it to the network for execution";

    fn build(display_order: usize) -> App<'a, 'b> {
        let subcommand = SubCommand::with_name(Self::NAME)
            .about(Self::ABOUT)
            .display_order(display_order)
            .arg(common::verbose::arg(DisplayOrder::Verbose as usize))
            .arg(common::rpc_id::arg(DisplayOrder::RpcId as usize));
        let subcommand = creation_common::apply_common_session_options(subcommand);
        let subcommand = creation_common::apply_common_payment_options(subcommand);
        creation_common::apply_common_creation_options(subcommand, true)
    }

    fn run(matches: &ArgMatches<'_>) {
        creation_common::show_arg_examples_and_exit_if_required(matches);

        let verbose = common::verbose::get(matches);
        let node_address = common::node_address::get(matches);
        let rpc_id = common::rpc_id::get(matches);
        let session = creation_common::parse_session_info(matches);
        let params = creation_common::construct_deploy(matches, session);

        let response = Self::request_with_map_params(verbose, &node_address, rpc_id, params);
        println!(
            "{}",
            serde_json::to_string_pretty(&response).expect("should encode to JSON")
        );
    }
}
