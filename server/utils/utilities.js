function haversineDistance(coords1, coords2) {
  const R = 6371;
  const lat1 = radians(coords1[0]);
  const lon1 = radians(coords1[1]);
  const lat2 = radians(coords2[0]);
  const lon2 = radians(coords2[1]);

  const dLat = lat2 - lat1;
  const dLon = lon2 - lon1;

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) * Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c;
}

function radians(degrees) {
  return (degrees * Math.PI) / 180;
}

function sortByDistance(arr) {
  const compareDistances = (a, b) => {
    return a.distance - b.distance;
  };

  arr.sort(compareDistances);

  return arr;
}

function calculateSlots(data) {
  let from = data.workingHours.from.split(":").map((item) => Number(item));

  let to = data.workingHours.to.split(":").map((item) => Number(item));

  from = from[0] * 60 + from[1];
  to = to[0] * 60 + to[1];

  let slots = [];
  while (from < to + 15) {
    slots.push(
      `${Math.floor(from / 60)}:${from % 60 === 0 ? "00" : from % 60}`
    );
    from += 15;
  }

  slots = slots
    .map((item, i) => {
      let slot = `${item} - ${slots[i + 1]}`;
      return { slot, isAvailable: true };
    })
    .slice(0, slots.length - 1);

  return slots;
}

function getTodayDate() {
  const today = new Date();
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, "0");
  const day = String(today.getDate()).padStart(2, "0");

  const dateString = `${day}-${month}-${year}`;

  return dateString;
}

module.exports = {
  haversineDistance,
  sortByDistance,
  calculateSlots,
  getTodayDate,
};
