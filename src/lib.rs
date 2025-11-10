use cosmwasm_std::{
    entry_point, to_json_binary, Binary, Deps, DepsMut, Env, MessageInfo, Response, StdResult,
};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct InstantiateMsg {
    pub count: i32,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    Increment {},
    Reset { count: i32 },
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum QueryMsg {
    GetCount {},
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq)]
pub struct CountResponse {
    pub count: i32,
}

const COUNT_KEY: &[u8] = b"count";

#[entry_point]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    msg: InstantiateMsg,
) -> StdResult<Response> {
    deps.storage.set(COUNT_KEY, &msg.count.to_be_bytes());
    Ok(Response::new().add_attribute("action", "instantiate"))
}

#[entry_point]
pub fn execute(
    deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    msg: ExecuteMsg,
) -> StdResult<Response> {
    match msg {
        ExecuteMsg::Increment {} => {
            let count = get_count(deps.as_ref())?;
            deps.storage.set(COUNT_KEY, &(count + 1).to_be_bytes());
            Ok(Response::new().add_attribute("action", "increment"))
        }
        ExecuteMsg::Reset { count } => {
            deps.storage.set(COUNT_KEY, &count.to_be_bytes());
            Ok(Response::new().add_attribute("action", "reset"))
        }
    }
}

#[entry_point]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::GetCount {} => {
            let count = get_count(deps)?;
            to_json_binary(&CountResponse { count })
        }
    }
}

fn get_count(deps: Deps) -> StdResult<i32> {
    let data = deps.storage.get(COUNT_KEY).unwrap_or_default();
    if data.is_empty() {
        return Ok(0);
    }
    let bytes: [u8; 4] = data.try_into().unwrap_or([0, 0, 0, 0]);
    Ok(i32::from_be_bytes(bytes))
}
