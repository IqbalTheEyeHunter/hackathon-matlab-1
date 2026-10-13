# hackathon-matlab-1
Repo for dumping crap for UTM Hackathon MATLAB for degree newbies.

## The Question for the Demonstration

#### Design a calculator that estimates the time required for a fixed monthly investment to reach a target real future value.

**Inputs:**
- $Y$: target amount in today’s RM, i.e., real value, with $Y>0$.
- $K$: fixed monthly contribution, made at the end of each month, with $K>0$.
- $r$: assumed constant effective annual return of a low-risk fixed-income fund, as a decimal.
- $q$: assumed constant annual inflation rate, as a decimal.

**Assumptions:**
- Returns compound monthly.
- Contributions are constant and never missed.
- There are no taxes, fees, or withdrawals.

**Task:**
Compute the smallest integer number of months $n$, and the corresponding time $T=n/12$ years, such that the inflation-adjusted real value of the investment is at least $Y$.

Use:

$$
r_{\text{real}}=\frac{1+r}{1+q}-1,\qquad
i=(1+r_{\text{real}})^{1/12}-1
$$

If $i\ne 0$, the real value after $n$ months is:

$$
FV(n)=K\frac{(1+i)^n-1}{i}
$$

If $i=0$, use:

$$
FV(n)=Kn
$$

Solve $FV(n)\ge Y$.

The calculator should also display the nominal accumulated value, total contributions, and total investment gain. If the goal is infeasible because $i<0$ and $Y\ge K/(-i)$, report that the target cannot be reached under the given assumptions.
