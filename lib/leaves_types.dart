class LeaveType {
  final int id;
  final String name;

  const LeaveType({required this.id, required this.name});
}

const List<LeaveType> leavesTypes = <LeaveType>[
  LeaveType(id: 1, name: "Test1"),
  LeaveType(id: 2, name: "Test2"),
  LeaveType(id: 3, name: "Byle co"),
];
