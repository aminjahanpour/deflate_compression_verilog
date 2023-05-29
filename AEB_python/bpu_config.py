for a in range(4, 17):
    print(f'{a}----------------------')

    mean = int(round(a / 3, 0))
    print(mean, mean, a - 2* mean)

    assert mean + mean + a - 2* mean == a


    max_ =int(0.61 * a)
    mid_ = int(0.35 * a)
    min_ = a - max_ - mid_
    print(max_ , mid_ , min_)
    assert max_ + mid_ + min_ == a
    assert min_>0

# print(max_, mid_, min_)
# print(max_, min_, mid_)
# print(mid_, min_, max_)
# print(mid_, max_, min_)
# print(min_, max_, mid_)
# print(min_, mid_, max_)
