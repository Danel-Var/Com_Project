import numpy as np
import matplotlib.pyplot as plt

DBG = False

################################## 
# Swinging pole class
##################################

class SwingingPole:

    """
    Pole sway simulator using the spectral-representation method
    Based on Hur et al. 'Millimeter Wave Beamforming for Wireless Backhaul and Access in Small Cell Networks'
    """

    def __init__(self,
                 T=100, Fs=2000, D=50,
                 u_avg=13,
                 m=5,
                 hight=10,
                 dp=0.5,
                 seed=None):

        self.T = T          # Simulation time [s]
        self.Fs = Fs        # Sampling rate [Hz]
        self.D = D          # Antennas distance [m]
        self.u_avg = u_avg  # Wind speed [m/s]
        self.rho_a = 1.22   # Air dansity [Kg/m^3]
        self.C_D = 0.5      # Drug coefficient [None]
        self.A_e = 0.09     # Affective pole area [m^2]
        self.m = m          # Pole and antenna mass [Kg]
        self.f_n = 1        # Natural pole oscilation frequency [Hz]
        self.zeta = 0.002   # Pole movement damping ratio [None]
        self.z0 = 2         # Terrain roughness [m]
        self.hight = hight  # Pole hight [m]
        self.dp = dp        # Pole diameter [m]
        self.S = 0.2        # Vortex parameter
        self.seed = seed

        self.t = None       # Time vector [s]
        self.Ld = None      # Displacement along the wind [m]
        self.Lc = None      # Displacement vertical to the wind [m]
        self.theta_d = None   # Affective misalignment angle along the win [deg]
        self.theta_c = None   # Affective misalignment angle vertical to the win [deg]

    def run(self):

        # Time and frequency grids
        N = int(self.T * self.Fs)
        dt = 1.0 / self.Fs
        t = np.arange(N) * dt
        df = self.Fs / N
        f = np.arange(N) * df

        """ Assuming wind only in the x and y directions since closness to the ground"""
        # Wind velocity field PSD - u = u_avg + Ud [d direction] + Uc [c direction]
        kappa = 0.5 * self.rho_a * self.C_D * self.A_e
        u_star = self.u_avg / (2.5 * np.log(self.hight / self.z0))
        f_vs = self.S * self.u_avg / self.dp
        Sud = (500 * u_star**2) / (np.pi * self.u_avg) * (1.0 / (1.0 + 500 * f / (2*np.pi*self.u_avg)))**(5.0/3.0)
        Suc = ( 75 * u_star**2) / (2*np.pi * self.u_avg) * (1.0 / (1.0 +  95 * f / (2*np.pi*self.u_avg)))**(5.0/3.0)

        # Applied forcs PSD
        SFd = (2 * kappa * self.u_avg)**2 * Sud
        SFc = (    kappa * self.u_avg)**2 * Suc

        """ Wind flowing torword the pole creates a vacume behind it which creating ocsilating drug force - vortex shreding"""
        # Vortex shedding PSD
        SF_vs = kappa**2 * 1.125 * np.sqrt(np.pi * np.divide(f, f_vs, out=np.zeros_like(f), where=f_vs!=0)) \
                * np.exp(-((1.0 - np.divide(f, f_vs, out=np.zeros_like(f), where=f_vs!=0))**2) / 0.18)

        # Mechanical pole transfer function
        ratio = np.divide(f, self.f_n, out=np.zeros_like(f), where=self.f_n!=0)
        Hm = 1.0 / (4.0 * self.m * np.pi**2 * self.f_n**2 *
                    np.sqrt((1 - ratio**2)**2 + (2*self.zeta*ratio)**2))
        SLd = np.abs(Hm)**2 * SFd
        SLc = np.abs(Hm)**2 * (SFc + SF_vs)

        # Finale movement PSD adding random phases
        Npos = N//2 + 1 if N % 2 == 0 else (N + 1)//2
        rng = np.random.default_rng(self.seed)
        phi1 = rng.random(Npos) * 2*np.pi
        phi2 = rng.random(Npos) * 2*np.pi
        Delta_f = self.Fs / N
        Sd_pos = (N/2.0) * np.sqrt(2.0 * SLd[:Npos] * Delta_f) * np.exp(1j * phi1)
        Sc_pos = (N/2.0) * np.sqrt(2.0 * SLc[:Npos] * Delta_f) * np.exp(1j * phi2)
        Sd_full = np.zeros(N, dtype=complex)
        Sc_full = np.zeros(N, dtype=complex)
        Sd_full[:Npos] = Sd_pos
        Sc_full[:Npos] = Sc_pos
        if N % 2 == 0:
            Sd_full[Npos:] = np.conj(Sd_pos[1:-1][::-1])
            Sc_full[Npos:] = np.conj(Sc_pos[1:-1][::-1])
        else:
            Sd_full[Npos:] = np.conj(Sd_pos[1:][::-1])
            Sc_full[Npos:] = np.conj(Sc_pos[1:][::-1])

        # Creating position vector using IFFT
        Ld = np.real(np.fft.ifft(Sd_full))
        Lc = np.real(np.fft.ifft(Sc_full))
        theta_d = np.degrees(np.arctan2(Ld, self.D))
        theta_c = np.degrees(np.arctan2(Lc, self.hight))
        self.t, self.Ld, self.Lc, self.theta_d, self.theta_c = t, Ld, Lc, theta_d, theta_c
        return theta_d, theta_c

    def plot_results(self):           # Continue - adjust to 2D
        """Plot time series and 3D sway trajectory."""
        if self.t is None or self.Ld is None:
            raise RuntimeError("Run the simulation first using .run()")

        fig = plt.figure(figsize=(12, 9))
        gs = GridSpec(3, 3, figure=fig)

        # 3D scatter
        ax3d = fig.add_subplot(gs[:, 1:], projection='3d')
        sc = ax3d.scatter(self.Lc*100.0, self.Ld*100.0, self.t, s=2, c=self.t)
        ax3d.set_title('Pole sway – $L_c(t)$ vs. $L_d(t)$')
        ax3d.set_xlabel('$L_c$ [cm]')
        ax3d.set_ylabel('$L_d$ [cm]')
        ax3d.set_zlabel('Time [s]')
        cb = fig.colorbar(sc, ax=ax3d, fraction=0.03, pad=0.08)
        cb.set_label('Time [s]')

        # Cross-wind
        ax1 = fig.add_subplot(gs[0, 0])
        ax1.plot(self.t, self.Lc*100.0)
        ax1.set_title('Pole sway – cross-wind $L_c(t)$')
        ax1.set_xlabel('Time [s]')
        ax1.set_ylabel('$L_c$ [cm]')

        # Along-wind
        ax2 = fig.add_subplot(gs[1, 0])
        ax2.plot(self.t, self.Ld*100.0)
        ax2.set_title('Pole sway – along-wind $L_d(t)$')
        ax2.set_xlabel('Time [s]')
        ax2.set_ylabel('$L_d$ [cm]')

        # Tilt angle
        ax3 = fig.add_subplot(gs[2, 0])
        ax3.plot(self.t, self.theta_d)
        ax3.set_title('Tilt angle $\\theta_L(t)$')
        ax3.set_xlabel('Time [s]')
        ax3.set_ylabel('$\\theta_L$ [deg]')

        fig.suptitle('Pole sway time series', fontsize=14)
        plt.tight_layout()
        plt.show()
    
def calc_theta_max(ant_num, alpha=0.3578):
    theta_bw = np.arcsin(0.891 / ant_num)
    theta_max = np.rad2deg(alpha * theta_bw)
    if DBG:
        print("Theta max = " + str(theta_max))
    return theta_max

def calc_ant_num(lo_freq, array_len):
    c = 3e8
    wl = c / lo_freq
    ant_num = np.round(array_len * 2 / wl)
    return ant_num

################################## 
# Main function
##################################

def main():
    # Parameters
    ant_num_list = calc_ant_num(90e9, np.array([0.10, 0.20, 0.30]))
    wind_speed_sweep = np.linspace(1, 30, 15)
    Fs = 1000
    num_of_repeats = 100
    plot_theta_c = True
    plot_theta_d = False

    # --- Figure setup before plotting ---
    plt.figure(figsize=(9, 6))
    plt.rcParams.update({
        "font.size": 13,
        "axes.titlesize": 20,
        "axes.labelsize": 20,
        "legend.fontsize": 16,
        "xtick.labelsize": 12,
        "ytick.labelsize": 12
    })

    colors = plt.cm.plasma(np.linspace(0, 1, len(ant_num_list)))
    markers = ['o', 's', '^', 'D', 'v', '<', '>', 'p', '*', 'h']

    # --- Run simulations and plot ---
    for color, marker, m in zip(colors, markers, ant_num_list):
        theta_max = calc_theta_max(m)

        # Wind sweep data
        wind_speed_swap_results = [[], []]
        wind_speed_swap = []

        for u in wind_speed_sweep:
            results = [[], []]
            for _ in range(num_of_repeats):
                pole = SwingingPole(T=2, Fs=Fs, seed=np.random.randint(0, 10), u_avg=u)
                theta_d, theta_c = pole.run()

                # Theta D handling
                start_pos = theta_d[0]
                for i in range(len(theta_d)):
                    if np.abs(theta_d[i] - start_pos) >= theta_max:
                        results[0].append(i / Fs)
                        break

                # Theta C handling
                start_pos = theta_c[0]
                for i in range(len(theta_c)):
                    if np.abs(theta_c[i] - start_pos) >= theta_max:
                        results[1].append(i / Fs)
                        break

            # Final results
            theta_d_coherence_time = np.mean(results[0]) if results[0] else np.inf
            theta_c_coherence_time = np.mean(results[1]) if results[1] else np.inf

            wind_speed_swap_results[0].append(theta_d_coherence_time)
            wind_speed_swap_results[1].append(theta_c_coherence_time)
            wind_speed_swap.append(u)

        # Smooth the results
        average_window = np.ones(5) / 5
        for axis in range(len(wind_speed_swap_results)):
            wind_speed_swap_results[axis] = np.convolve(wind_speed_swap_results[axis], average_window, 'same')

        # Plot the results
        label = f"M = {int(m)}"
        if plot_theta_d:
            plt.semilogy(wind_speed_swap, wind_speed_swap_results[0],
                         linestyle='-', marker=marker, color=color, label=f'Along-wind ({label})')
        if plot_theta_c:
            plt.semilogy(wind_speed_swap, wind_speed_swap_results[1],
                         linestyle='--', marker=marker, color=color, label=f'Cross-wind ({label})')
        if not plot_theta_c and not plot_theta_d:
            print("Plot at least one axis !")
            return

    # --- Finalize plot ---
    plt.xlabel("Average wind speed [m/s]")
    plt.ylabel("Beam coherence time [s]")
    #plt.title("Beam Coherence Time vs Wind Speed\nfor Different Antenna Array Sizes",
    #          fontsize=18, fontweight='bold', pad=15)
    plt.grid(True, which="both", linestyle="--", alpha=0.6)
    plt.legend(frameon=True, shadow=True, loc="best", ncol=1)
    plt.tight_layout()
    plt.show()

def tmp_main():
    # --- Compute theta_max for a range of antenna counts ---
    ant_num = np.arange(20, 260, 20)
    width = [calc_theta_max(i) for i in ant_num]

    # --- Figure setup ---
    plt.figure(figsize=(8.5, 5.5))
    plt.rcParams.update({
        "font.size": 13,
        "axes.titlesize": 20,
        "axes.labelsize": 20,
        "legend.fontsize": 16,
        "xtick.labelsize": 12,
        "ytick.labelsize": 12
    })

    # --- Plot ---
    plt.plot(ant_num, width, marker='o', linestyle='-', linewidth=2.0, markersize=6, color='#0072B2')

    # --- Labels and aesthetics ---
    plt.xlabel("Number of antenna elements $M$")
    plt.ylabel("Maximum tolerated misalignment $\\theta_{max}$ [°]")
    plt.grid(True, which="both", linestyle="--", alpha=0.6)

    # --- Finish ---
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    # main()
    tmp_main()