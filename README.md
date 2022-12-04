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

<h2 align="center">Contoh Studikasus</h2>

### Untuk dokumentasi running code dapat dilihat [disini](https://github.com/mrayhanaryana/UTS_robotik/tree/main/kodingan/doc_%20pdf) atau [source code](https://github.com/mrayhanaryana/UTS_robotik/blob/main/kodingan/symforce.ipynb)

Kali ini studi kasus yang dilakukan adalah robot akan bergerak pada bidang 2 dimensi untuk memperkirakan pose dari langkah selanjutnya menggunakan pengukuran kebisingan. Robot akan mengukur sudut relatif landmark dan jarak tempuh dengan sensor odometri.

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










