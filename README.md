<h1 align="center">UTS ROBOTIK/Review dokumentasi- Symforce</h1>
<h3 align="center">Oleh: Mohammad Rayhan Aryana - 1103194042</h3>

![image](https://symforce.org/docs/static/images/symforce_banner.png#gh-light-mode-only)

Symforce merupakan opensource library untuk komputasi simbolik untuk pembuatan aplikasi robotik seperti estimasi keadaan, perencanaan gerak dan kontrol. Symforce menggabungkan pengembangan dan fleksibilitas dari matematika simbolik dengan kinerja kode otomatis dan dioptimalkan dalam bahasa C++ atau bahasa runtime target apapun.

Dalam symforce terdapat 3 independen sistem yang penting yaitu:
- Symbolic Toolkit
- Code Generator
- Optimization Library 

![image](https://symforce.org/docs/static/images/symforce_diagram.png)

Contoh dari implementasi symforce adalah:
- Computer Vision
- State Estimation
- Motion Planning
- Robot Controls

<h2 align="center">Spesifikasi Hardware</h2>

Agar dapat menjalankan simulasi symforce secara optimal bertikut rekomendasi spesifikasi perangkat yang disarankan:

- CPU 4 core
- RAM 8 GB
- Mem 50 GB

atau bisa juga menggunakan alternatif lain seperti [github codespace](https://github.com/features/codespaces)

<h2 align="center">Software yang terinstall</h2>

Berikut beberapa software yang menjadi rekomendasi penulis:

- Ubuntu 20.04 OS
- Python 3.8+
- Jupyter notebook
- Visual studio code editor

<h2 align="center">Keunggulan symforce</h2>

- Termasuk ke dalam Tangent-space Optimization library tercepat berdasarkan grafik faktor untuk bahasa pemrograman C++ dan Python
- Dapat melakukan komputasi untuk menghitung Tangent Space-Jacobian dengan optimal
- Dapat meminimalkan bug, mengurangi duplikasi serta pembuatan code generation dengan runtime yang cepat
- Memiliki flattening computation dan memanfaatkan sparsity yang dapat menghasilkan 10x percepatan apabila dibandingkan dengan autodiff standar
- Dapat mengimplementasikan simbolik geometri dan juga tipe kamera dengan menggunakan operasi Lie Group

<h2 align="center">Contoh Studi kasus</h2>

### Untuk dokumentasi running code dapat dilihat [disini](https://github.com/mrayhanaryana/UTS_robotik/tree/main/kodingan/doc_%20pdf) atau [source code](https://github.com/mrayhanaryana/UTS_robotik/blob/main/kodingan/symforce.ipynb)

Kali ini studi kasus yang dilakukan adalah robot akan bergerak pada bidang 2 dimensi untuk memperkirakan pose dari langkah selanjutnya menggunakan pengukuran kebisingan. Robot akan mengukur sudut relatif landmark dan jarak tempuh dengan sensor odometri.

![image](https://symforce.org/docs/static/images/robot_2d_localization/problem_setup.png)

Menurut studi kasus diatas tahapan yang akan dilakukan adalah:

1. Import libraru symforce

```python
import symforce.symbolic as sf
```

2. Membuat simbolik pose 2 dimensi dan lokasi landmark, menggunakan method symbolic pada library symforce 

```python
pose = sf.Pose2(
    t=sf.V2.symbolic("t"),
    R=sf.Rot2.symbolic("R")
)
landmark = sf.V2.symbolic("L")
```

3. Transformasi landmark kedalam frame lokal robot

```python
landmark_body = pose.inverse() * landmark
```

4. Inisialisasi metode jacobian dari landmark body-frame dengan pendekatan tangent-space dari pose 2

```python
landmark_body.jacobian(pose)
```

5. Melakukan perhitungan sudut relatif bearing

```python
sf.atan2(landmark_body[1], landmark_body[0])
```
#### Note Pada bagian ini, `atan2` merupakan sebuah singular dengan koordinat (0, 0). Dengan menggunakan SymForce kita dapat mengatasi ini dengan menambahkan simbol ϵ (epsilon) untuk mempertahankan nilai ekspresi dalam batas ` ϵ → 0 `, tetapi nilai evaluasi saat runtime dapat menghasilkan nonzero yang sangat kecil.

6. Menambahkan fungsi epsilon 

```python
sf.V3.symbolic("x").norm(epsilon=sf.epsilon())
```

<h2 align="center">Pembahasan masalah</h2>

Pada permodelan kasus ini kita akan menggunakan factor graph dan nonlinear least-squares. Berikut tahapannya:

1. Menggunakan fungsi non-zero epsilon pada librari symforce unutk mencekah singularitas

```python
import symforce
symforce.set_epsilon_to_symbol()
```

2. Jika sudah terdefinisi kita bisa menggunakan fungsi numerical value dan unknown poses

```python
import numpy as np
from symforce.values import Values

num_poses = 3
num_landmarks = 3

initial_values = Values(
    poses=[sf.Pose2.identity()] * num_poses,
    landmarks=[sf.V2(-2, 2), sf.V2(1, -3), sf.V2(5, 2)],
    distances=[1.7, 1.4],
    angles=np.deg2rad([[145, 335, 55], [185, 310, 70], [215, 310, 70]]).tolist(),
    epsilon=sf.numeric_epsilon,
)
```

3. Melakukan perhitungan matematika yang telah didefinisikan sebelumnya menggunakan fungsi symbolic residual:

```python
def bearing_residual(
    pose: sf.Pose2, landmark: sf.V2, angle: sf.Scalar, epsilon: sf.Scalar
) -> sf.V1:
    t_body = pose.inverse() * landmark
    predicted_angle = sf.atan2(t_body[1], t_body[0], epsilon=epsilon)
    return sf.V1(sf.wrap_angle(predicted_angle - angle))
```

#### Fungsi ini akan mengambil variabel pose dan landmar setelah itu akan mengembalikan error yang diperolah dari sudut bearing.

4. Menyederhanakan nilai residual dari jarak yang ditempuh 

```python
def odometry_residual(
    pose_a: sf.Pose2, pose_b: sf.Pose2, dist: sf.Scalar, epsilon: sf.Scalar
) -> sf.V1:
    return sf.V1((pose_b.t - pose_a.t).norm(epsilon=epsilon) - dist)
```

5. Membuat object 'factor' dari residual dan menentukan key sesuai kebutuhan

```python
from symforce.opt.factor import Factor

factors = []

# Bearing factors
for i in range(num_poses):
    for j in range(num_landmarks):
        factors.append(Factor(
            residual=bearing_residual,
            keys=[f"poses[{i}]", f"landmarks[{j}]", f"angles[{i}][{j}]", "epsilon"],
        ))

# Odometry factors
for i in range(num_poses - 1):
    factors.append(Factor(
        residual=odometry_residual,
        keys=[f"poses[{i}]", f"poses[{i + 1}]", f"distances[{i}]", "epsilon"],
    ))
```

6. menentukan poses dari robot dengan meminimalkan residual dari factor graph dengan mengansumsikan posisi landmark menjadi bentuk yang lebih mudah untuk diamati

```python
from symforce.opt.optimizer import Optimizer

optimizer = Optimizer(
    factors=factors,
    optimized_keys=[f"poses[{i}]" for i in range(num_poses)],
    # So that we save more information about each iteration, to visualize later:
    debug_stats=True,
)
```

7. Menampilkan hasil dari optimalisasi dan statistik error

```python
result = optimizer.optimize(initial_values)

from data.plotting import plot_solution
plot_solution(optimizer, result)
```
#### Tampilan visual hasil optimalisasi:

![image](https://symforce.org/docs/static/images/robot_2d_localization/iterations.gif)

#### Keterangan:
* Bentuk lingkaran berwarna orange merepresentasikan `fixed landmarks`
 * Bentuk lingkaran biru merepresentasikan `robot`
 * Garis putus-putus merepresentasikan `perhitungan bearing`


<h1 align="center">Lampiran</h1>

[symforce.org](https://symforce.org/)

[master source code](https://github.com/symforce-org/symforce/tree/main/symforce/examples/robot_2d_localization)










