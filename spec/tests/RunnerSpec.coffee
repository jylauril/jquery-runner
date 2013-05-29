
describe "Dependencies", ->
  it "should have jQuery", ->
    expect(window.$).toBeDefined()

describe "Runner", ->
  it "should be defined", ->
    expect($().runner).toBeDefined()
  it "should be a function", ->
    expect($().runner).toBeOfType('function')
