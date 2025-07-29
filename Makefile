-include .env

all : install fbuild

install :; forge soldeer install

update :; forge soldeer update

format :; forge fmt

compile :; forge compile

fbuild :; forge build

ftest :; forge test

snapshot :; forge snapshot

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1