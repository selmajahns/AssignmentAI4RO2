### Q1 - Problem 1
Found Plan:
0.0: (move r p1 p2)
1.0: (move r p2 p3)
2.0: (inspect-and-finds-infested r p3)
3.0: (treat r p3)
4.0: (report-treated r p3)

Plan-Length:5
Metric (Search):5.0

### Q1 - Problem 2
Found Plan:
0.0: (move r p1 p2)
1.0: (move r p2 p3)
2.0: (inspect-and-finds-infested r p3)
3.0: (treat r p3)
4.0: (report-treated r p3)

Plan-Length:5
Metric (Search):5.0

# comment to result:
The plan appears identical to Problem 1 but represents a fundamentally different decision. The robot passes through p2 which is also infested, but without treating it and instead proceeds directly to p3. This is not accidental. With capacity 1 and the goal requiring (not (infested p5)), treating p2 first would use all capacity and leave p3 infested, making the goal unreachable. The planner correctly identifies p3 as the strategic priority.


### Q2 - Problem 1
Found Plan:
0: (start-move r p1 p2)
0: -----waiting---- [1.0]
1.0: (start-move r p2 p3)
1.0: -----waiting---- [2.0]
2.0: (inspect-and-finds-infested r p3)
2.0: (start-treat r p3)
2.0: -----waiting---- [4.0]
4.0: (report-treated r p3)

Plan-Length:12
Elapsed Time: 4.0
Metric (Search):9.0


### Q2 - Problem 2
Found Plan:
0: (start-move r p1 p2)
0: -----waiting---- [1.0]
1.0: (start-move r p2 p3)
1.0: -----waiting---- [2.0]
2.0: (inspect-and-finds-infested r p3)
2.0: (start-move r p3 p4)
2.0: -----waiting---- [3.0]
3.0: (inspect-and-finds-infested r p4)
3.0: -----waiting---- [4.0]
4.0: (start-treat r p4)
4.0: -----waiting---- [6.0]
6.0: (report-treated r p4)
6.0: (start-move r p4 p3)
6.0: -----waiting---- [7.0]
7.0: (start-treat r p3)
7.0: -----waiting---- [9.0]
9.0: (report-treated r p3)

Plan-Length:27
Elapsed Time: 9.0
Metric (Search):19.0