// borrowed. think of where it makes sense to put this
// maybe in global app settings... but would want it editable at the mobile level so maybe not?

/*
const BAR = 20;

const PLATES = [
  1.25,
  2.5,
  2.5,
  5,
  5,
  10,
  10,
  20,
  20,
];


const sumPlates = (plates) => {
  return plates.reduce((acc, plate) => {
    return acc + (plate * 2);
  }, 0);
};

const rack = (targetWeight) => {
  const sortedPlates = PLATES.sort((a, b) => b - a);

  const rackedPlates = sortedPlates.reduce((acc, plate) => {
    if ((BAR + (plate * 2) + sumPlates(acc)) > targetWeight) {
      // Calculate here the closest possible rack weight
      return acc;
    }

    acc.push(plate);

    return acc;
  }, []);

  return {
    targetWeight,
    barbellWeight: BAR + sumPlates(rackedPlates),
    plates: rackedPlates,
  };
};
*/
