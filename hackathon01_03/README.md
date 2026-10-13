Third solution. Binary search + closed forme on ceiling

- **Closed-form with ceiling**  
  For $i\ne0$:

$$
n=\left\lceil\frac{\ln(1+Yi/K)}{\ln(1+i)}\right\rceil
$$

  For $i=0$:

$$
n=\left\lceil\frac{Y}{K}\right\rceil
$$
  
  Then verify $FV(n)\ge Y$ and $FV(n-1)<Y$. This avoids the while-loop.

- **Binary search on integer $n$**  
  Since $FV(n)$ is monotonic increasing, binary search between $0$ and an upper bound found by doubling is robust and fast.

