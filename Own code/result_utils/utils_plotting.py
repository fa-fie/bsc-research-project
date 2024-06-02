import os

# Create all needed directories
def create_dirs(directory, metrics):
    plt_dir = os.path.join(directory, 'Plots')
    if not os.path.exists(plt_dir):
        os.makedirs(plt_dir)

    hist_dir = os.path.join(plt_dir, 'Histograms')
    if not os.path.exists(hist_dir):
        os.makedirs(hist_dir)

    ecum_dir = os.path.join(plt_dir, 'Cumulative distributions')
    if not os.path.exists(ecum_dir):
        os.makedirs(ecum_dir)

    means_dir = os.path.join(plt_dir, 'Means')
    if not os.path.exists(means_dir):
        os.makedirs(means_dir)

    scatter_dir = os.path.join(plt_dir, 'Scatter')
    if not os.path.exists(scatter_dir):
        os.makedirs(scatter_dir)

    raincloud_dir = os.path.join(plt_dir, 'Raincloud')
    if not os.path.exists(raincloud_dir):
        os.makedirs(raincloud_dir)

    heatmap_dir = os.path.join(plt_dir, 'Heatmap')
    if not os.path.exists(heatmap_dir):
        os.makedirs(heatmap_dir)

    for metric in metrics:
        if not os.path.exists(os.path.join(means_dir, metric)):
            os.makedirs(os.path.join(means_dir, metric))

        if not os.path.exists(os.path.join(scatter_dir, metric)):
            os.makedirs(os.path.join(scatter_dir, metric))

        if not os.path.exists(os.path.join(raincloud_dir, metric)):
            os.makedirs(os.path.join(raincloud_dir, metric))

    return {
        'hist_dir': hist_dir,
        'ecum_dir': ecum_dir,
        'means_dir': means_dir,
        'scatter_dir': scatter_dir,
        'raincloud_dir': raincloud_dir,
        'heatmap_dir': heatmap_dir
    }