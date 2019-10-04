var {Shop, Item} = require('../src/gilded_rose.js');
describe("Gilded Rose", function() {

  it("should decrease quality by 1 by default", function() {
    const gildedRose = new Shop([ new Item("foo", 10, 10) ]);
    const items = gildedRose.updateQuality();
    expect(items[0].quality).toEqual(9);
  });
  it("should never decrease quality of Sulfuras, Hand of Ragnaros", function() {
    const gildedRose = new Shop([ new Item("Sulfuras, Hand of Ragnaros", 10, 10) ]);
    const items = gildedRose.updateQuality();
    expect(items[0].quality).toEqual(10);
  });
  it("should decrease quality by 2 once sellIn is due, by default", function() {
    const gildedRose = new Shop([ new Item("foo", 0, 10) ]);
    const items = gildedRose.updateQuality();
    expect(items[0].quality).toEqual(8);
  });
  it("should increase quality by 1 for Aged Brie", function() {
    const gildedRose = new Shop([ new Item("Aged Brie", 10, 10) ]);
    const items = gildedRose.updateQuality();
    expect(items[0].quality).toEqual(11);
  });
  it("Aged Brie cannot exceed 50 in quality", function() {
    const gildedRose = new Shop([ new Item("Aged Brie", 10, 50) ]);
    const items = gildedRose.updateQuality();
    expect(items[0].quality).toEqual(50);
  });
  it("quality cannot be negative", function() {
    const gildedRose = new Shop([ new Item("foo", 0, 0) ]);
    const items = gildedRose.updateQuality();
    expect(items[0].quality).toEqual(0);
  });

});