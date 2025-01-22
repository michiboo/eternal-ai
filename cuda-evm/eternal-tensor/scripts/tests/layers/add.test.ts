import { expect, assert } from 'chai';
import { BigNumber } from 'ethers';
import { ethers } from 'hardhat';
import { AddLayer } from '../../../typechain-types';
import { RandomSeed, create } from 'random-seed';
import { fromFloat, isBigNumberArrayEqual, toFloat, randomFloatArray, recursiveFromFloat, recursiveToFloat, encodeData, deflatten, decodeData, isFloatArrayEqual} from '../../libraries/utils';
import { Tensor } from '../../libraries/tensorData';
import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

const abic = ethers.utils.defaultAbiCoder;
const TEST_FOLDER = "scripts/tests/layers"
const SCRIPT_PATH = path.join(TEST_FOLDER, 'add.py');
const OUTPUT_PATH = path.join(TEST_FOLDER, 'output.txt');
const CONFIG_PATH = path.join(TEST_FOLDER, 'config.json');
const PRECISION = 1e-3;

let addContract: AddLayer, randomizer: RandomSeed;

async function deployAddLayer() {
    const configData = abic.encode([], []);
    
    const AddLayer = await ethers.getContractFactory('AddLayer');
    addContract = await AddLayer.deploy(configData);
    await addContract.deployed();
}

async function forwardAddLayer(addContract: AddLayer, input1: any, input2: any): Promise<any> {
    const inputTensors: Tensor[] = [Tensor.fromFloatArray(input1), Tensor.fromFloatArray(input2)];
    console.log(inputTensors[0]);
    const outputTensor = await addContract.forward(inputTensors);
    const output = new Tensor(outputTensor.data, outputTensor.shapes);
    return output.toFloatArray();
}

async function getKerasAddOutput(input1: number[], input2: number[]) {
    const config = {
        input1,
        input2,
    }
    fs.writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2));

    let cmd = `python ${SCRIPT_PATH} --config-path ${CONFIG_PATH} --output-path ${OUTPUT_PATH}`;
    execSync(cmd);

    const data = fs.readFileSync(OUTPUT_PATH).toString();
    const output = JSON.parse(data);
    fs.rmSync(CONFIG_PATH);
    fs.rmSync(OUTPUT_PATH);

    return output;
}

describe('AddLayer', async () => {
    before(async () => {
        const seed = new Date().toLocaleString()
        console.log("Seed random: \"" + seed + "\"")
        randomizer = create(seed);
    });

    describe('1. deploy', async () => {
        it ('1.1. Manual test', async () => {

            await deployAddLayer();
        });
    });

    describe('2. forward', async () => {
        it ('2.1. Forward pass test with 3D tensor', async () => {

            await deployAddLayer();
            console.log("Model deployed");

            const testInput1 =
                [
                    [1.0, 2.0, 3.0],
                    [5.0, 6.0, 7.0],
                    [9.0, 10.0, 11.0]
                ];
            const testInput2 =
                [
                    [3.0, 5.0, 6.0],
                    [-3.0, 6.0, 12.0],
                    [-2.0, 1.0, 0.0]
                ];

            const expectedOutput = [[4.0, 7.0, 9.0],
                                    [2.0, 12.0, 19.0],
                                    [7.0, 11.0, 11.0],
            ];
            
            const output32x32 = await forwardAddLayer(addContract,testInput1, testInput2);

            expect(isFloatArrayEqual(output32x32, expectedOutput, PRECISION)).to.equal(true);
        });

        it ('2.2. Random test', async () => {

            const inputHeight = randomizer.intBetween(3,6);
            const inputWidth = randomizer.intBetween(3,6);
            const inputChannel = randomizer.intBetween(3,6);
            const input1 = randomFloatArray(randomizer,[inputHeight, inputWidth, inputChannel], -5.0, 5.0);
            const input2 = randomFloatArray(randomizer,[inputHeight, inputWidth, inputChannel], -5.0, 5.0);

            const expectedOutput = await getKerasAddOutput(input1, input2);

            await deployAddLayer();
            console.log("Model deployed");
            
            const output = await forwardAddLayer(addContract,input1, input2);

            expect(isFloatArrayEqual(output, expectedOutput, PRECISION)).to.equal(true);
        });
    }); 
});
