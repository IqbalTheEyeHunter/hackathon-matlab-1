Second solution

### 1. Clarify the model first, as real

Decide whether \(K\) is **real** or **nominal**. For a hackathon, defining \(K\) as a constant **real** monthly contribution is simpler and more intuitive for long-term planning. Then use:

- Real annual return: \(r_{\text{real}}=\frac{1+r}{1+q}-1\)
- Real monthly rate: \(i=(1+r_{\text{real}})^{1/12}-1\)
- Real future value after \(n\) months:
  \[
  FV_{\text{real}}(n)=K\frac{(1+i)^n-1}{i}\quad(i\ne0)
  \]
  \[
  FV_{\text{real}}(n)=Kn\quad(i=0)
  \]
- Solve \(FV_{\text{real}}(n)\ge Y\) for the smallest integer \(n\).
- Nominal future value: \(FV_{\text{nominal}}(n)=FV_{\text{real}}(n)(1+q)^{n/12}\).
- Total nominal contributions: as above.
- Nominal gain: \(FV_{\text{nominal}}(n)-C_{\text{nominal}}(n)\).

